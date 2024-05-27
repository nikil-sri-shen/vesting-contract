;; Owner
(define-constant CONTRACT_OWNER tx-sender)

;; Errors
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_DATA_NOT_FOUND (err u101))
(define-constant ERR_NO_AMOUNT_VALUE (err u102))
(define-constant ERR_CLAIMER_ONLY (err u103))
(define-constant ERR_UNLOCK_HEIGHT_NOT_REACHED (err u104))
(define-constant ERR_NO_EXPIRY_VALUE (err u105))
(define-constant ERR_REACHED_MAX_LEN (err u106))

;; Data Variables
(define-data-var last-id uint u0)
(define-data-var id-to-remove uint u0)

;; Map to store locked-token by users
(define-map locked-tokens uint {
    id: uint,
    maker: principal,
    taker: principal,
    amount: uint,
    expiry: uint,
})

;; Map to store ids of makers alone
(define-map makers-id principal (list 1000 uint))

;; Map to store ids of takers alone
(define-map takers-id principal (list 1000 uint))

;; Function to retrieve makers details
(define-read-only (get-maker-details) 
    (let
        (
            (ids (default-to (list) (map-get? makers-id tx-sender)))
        )
        (map get-maker-taker-tuple ids)
    )
)

;; Function to retrieve takers details
(define-read-only (get-taker-details) 
    (let
        (
            (ids (default-to (list) (map-get? takers-id tx-sender)))
        )
        (map get-maker-taker-tuple ids)
    )
)

;; Helper function to retrieve makers or takers details
(define-private (get-maker-taker-tuple (id uint))
    (let
        (
            (output {id:none, maker:none, taker:none, amount:none, expiry:none})
        )
        (ok (merge output (unwrap! (map-get? locked-tokens id) ERR_DATA_NOT_FOUND)))
    )
)

;; Helper function to remove ids from list
(define-read-only (remove-ids (values uint))
    (not (is-eq values (var-get id-to-remove)))
)

;; Function to get maker taker details from a id
(define-read-only (get-maker-taker-detail-id (id uint))
    (map-get? locked-tokens id)
)

;; Function to lock tokens by any tx-sender
(define-public (lock (taker principal) (amount uint) (expiry uint))
    (let
        (
            (new-id (+ (var-get last-id) u1))
            (expiry-days (+ block-height (* expiry u144)))
            (maker tx-sender)
        )
        (asserts! (> amount u0) ERR_NO_AMOUNT_VALUE)
        (asserts! (> expiry u0) ERR_NO_EXPIRY_VALUE)
        (if (is-some (map-get? makers-id tx-sender)) 
            (begin 
                (map-set makers-id tx-sender (unwrap! (as-max-len? (append (default-to (list) (map-get? makers-id maker)) new-id) u100) ERR_DATA_NOT_FOUND))
                ;; #[allow(unchecked_data)]
                (map-set takers-id taker (unwrap! (as-max-len? (append (default-to (list) (map-get? takers-id taker)) new-id) u100) ERR_DATA_NOT_FOUND))
            )
            (begin
                (map-set makers-id tx-sender (list new-id))
                ;; #[allow(unchecked_data)]
                (map-set takers-id taker (list new-id))
            )
        )
        ;; #[allow(unchecked_data)]
        (map-set locked-tokens new-id {id: new-id, maker: tx-sender, taker: taker, amount: amount, expiry: expiry-days})
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (var-set last-id new-id)
        (ok new-id)
    )
)

;; Function to claim locked token by corresponding tx-sender
(define-public (claim (id uint)) 
    (let
        (
            (data (unwrap! (map-get? locked-tokens id) ERR_DATA_NOT_FOUND))
            (maker (get maker data))
            (taker tx-sender)
            (expiry (get expiry data))
        )
        (asserts! (is-some (map-get? locked-tokens id)) ERR_DATA_NOT_FOUND)
        (asserts! (is-eq tx-sender taker) ERR_CLAIMER_ONLY)
        (asserts! (> block-height expiry ) ERR_UNLOCK_HEIGHT_NOT_REACHED)
        (var-set id-to-remove id)
        (try! (as-contract (stx-transfer? (get amount data) tx-sender taker)))
        (map-set makers-id maker (filter remove-ids (default-to (list) (map-get? makers-id maker))))
        (map-set takers-id tx-sender (filter remove-ids (default-to (list) (map-get? takers-id taker))))
        (map-delete locked-tokens id)
        (var-set id-to-remove u0)
        (ok id)
    )
)