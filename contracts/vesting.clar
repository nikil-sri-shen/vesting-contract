(use-trait ft-trait .sip010.sip010-ft-trait)
(use-trait nft-trait .sip009.sip009-nft-trait)
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
(define-constant ERR_FT_TOKEN_NOT_MATCH (err u107))

;; Data Variables
(define-data-var last-ft-id uint u0)
(define-data-var last-nft-id uint u0)
(define-data-var id-to-remove uint u0)

;; Map to store locked-fts by users
(define-map locked-fts uint {
    id: uint,
    ft-token: principal,
    maker: principal,
    taker: principal,
    amount: uint,
    expiry: uint,
})

;; Map to store locked-nfts by users
(define-map locked-nfts uint {
    id: uint,
    nft-token: principal,
    nft-id: uint,
    maker: principal,
    taker: principal,
    expiry: uint,
})

;; Map to store ft ids of makers and takers
(define-map makers-takers-ft-ids principal (list 1000 uint))
;; Map to store nft ids of makers and takers
(define-map makers-takers-nft-ids principal (list 1000 uint))

;; Function to retrieve ft makers details
(define-read-only (get-ft-maker-list (maker principal)) 
    (let
        (
            (ids (default-to (list) (map-get? makers-takers-ft-ids maker)))
        )
        (asserts! (is-some (map-get? makers-takers-ft-ids maker)) ERR_DATA_NOT_FOUND)
        (ok (map get-ft-maker-helper ids))
    )
)

;; Function to retrieve nft makers details
(define-read-only (get-nft-maker-list (maker principal)) 
    (let
        (
            (ids (default-to (list) (map-get? makers-takers-nft-ids maker)))
        )
        (asserts! (is-some (map-get? makers-takers-nft-ids maker)) ERR_DATA_NOT_FOUND)
        (ok (map get-nft-maker-helper ids))
    )
)

;; Function to retrieve ft takers details
(define-read-only (get-ft-taker-list (taker principal)) 
    (let
        (
            (ids (default-to (list) (map-get? makers-takers-ft-ids taker)))
        )
        (asserts! (is-some (map-get? makers-takers-ft-ids taker)) ERR_DATA_NOT_FOUND)
        (ok (map get-ft-taker-helper ids))
    )
)

;; Function to retrieve nft takers details
(define-read-only (get-nft-taker-list (taker principal)) 
    (let
        (
            (ids (default-to (list) (map-get? makers-takers-nft-ids taker)))
        )
        (asserts! (is-some (map-get? makers-takers-nft-ids taker)) ERR_DATA_NOT_FOUND)
        (ok (map get-nft-taker-helper ids))
    )
)

;; Helper function to retrieve ft makers or takers details
(define-private (get-ft-maker-helper (id uint))
    (let
        (
            (output {id:none, ft-token:none, maker:none, taker:none, amount:none, expiry:none})
            (wrong {id:u0, ft-token:tx-sender, maker:tx-sender, taker:tx-sender, amount:u0, expiry:u0})
            (data (unwrap! (map-get? locked-fts id) ERR_DATA_NOT_FOUND))
            (maker (get maker data))
        )
        (if (is-eq maker tx-sender) 
            (ok (merge output data))
            (ok  wrong)
        )
    )
)

;; Helper function to retrieve nft makers or takers details
(define-private (get-nft-maker-helper (id uint))
    (let
        (
            (output {id:none, nft-token:none, maker:none, taker:none, nft-id:none, expiry:none})
            (wrong {id:u0, nft-token: tx-sender, maker:tx-sender, taker:tx-sender, nft-id:u0, expiry:u0})
            (data (unwrap! (map-get? locked-nfts id) ERR_DATA_NOT_FOUND))
            (maker (get maker data))
        )
        (if (is-eq maker tx-sender) 
            (ok (merge output data))
            (ok  wrong)
        )
    )
)

;; Helper function to retrieve ft makers or takers details
(define-private (get-ft-taker-helper (id uint))
    (let
        (
            (output {id:none, ft-token:none, maker:none, taker:none, amount:none, expiry:none})
            (wrong {id:u0, ft-token:tx-sender, maker:tx-sender, taker:tx-sender, amount:u0, expiry:u0})
            (data (unwrap! (map-get? locked-fts id) ERR_DATA_NOT_FOUND))
            (taker (get taker data))
        )
        (if (is-eq taker tx-sender) 
            (ok (merge output data))
            (ok wrong)
        )
    )
)

;; Helper function to retrieve nft makers or takers details
(define-private (get-nft-taker-helper (id uint))
    (let
        (
            (output {id:none, nft-token:none, maker:none, taker:none, nft-id:none, expiry:none})
            (wrong {id:u0, nft-token: tx-sender, maker:tx-sender, taker:tx-sender, nft-id:u0, expiry:u0})
            (data (unwrap! (map-get? locked-nfts id) ERR_DATA_NOT_FOUND))
            (taker (get taker data))
        )
        (if (is-eq taker tx-sender) 
            (ok (merge output data))
            (ok wrong)
        )
    )
)

;; Helper function to remove ids from list
(define-private (remove-ids (values uint))
    (not (is-eq values (var-get id-to-remove)))
)

;; Function to get ft maker taker details from a id
(define-read-only (get-ft-maker-taker-detail-id (id uint))
    (map-get? locked-fts id)
)

;; Function to get nft maker taker details from a id
(define-read-only (get-nft-maker-taker-detail-id (id uint))
    (map-get? locked-nfts id)
)

;; Function to lock-ft tokens by any tx-sender
(define-public (lock-ft (ft-token <ft-trait>) (taker principal) (amount uint) (expiry uint))
    (let
        (
            (new-id (+ (var-get last-ft-id) u1))
            (expiry-days (+ block-height (* expiry u144)))
            (maker tx-sender)
        )
        (asserts! (> amount u0) ERR_NO_AMOUNT_VALUE)
        (asserts! (> expiry u0) ERR_NO_EXPIRY_VALUE)
        (if (is-some (map-get? makers-takers-ft-ids tx-sender)) 
            (begin 
                (map-set makers-takers-ft-ids tx-sender (unwrap! (as-max-len? (append (default-to (list) (map-get? makers-takers-ft-ids maker)) new-id) u100) ERR_DATA_NOT_FOUND))
                ;; #[allow(unchecked_data)]
                (map-set makers-takers-ft-ids taker (unwrap! (as-max-len? (append (default-to (list) (map-get? makers-takers-ft-ids taker)) new-id) u100) ERR_DATA_NOT_FOUND))
            )
            (begin
                (map-set makers-takers-ft-ids tx-sender (list new-id))
                ;; #[allow(unchecked_data)]
                (map-set makers-takers-ft-ids taker (list new-id))
            )
        )
        ;; #[allow(unchecked_data)]
        (map-set locked-fts new-id {id: new-id, ft-token: (contract-of ft-token),maker: tx-sender, taker: taker, amount: amount, expiry: expiry-days})
        ;; #[allow(unchecked_data)]
        (try! (contract-call? ft-token transfer amount maker (as-contract tx-sender) none))
        (var-set last-ft-id new-id)
        (ok new-id)
    )
)

;; Function to lock-nft tokens by any tx-sender
(define-public (lock-nft (nft-token <nft-trait>) (taker principal) (nft-id uint) (expiry uint))
    (let
        (
            (new-id (+ (var-get last-nft-id) u1))
            (expiry-days (+ block-height (* expiry u144)))
            (maker tx-sender)
        )
        (asserts! (is-some (unwrap! (contract-call? nft-token get-owner nft-id) ERR_DATA_NOT_FOUND)) ERR_DATA_NOT_FOUND)
        (asserts! (> expiry u0) ERR_NO_EXPIRY_VALUE)
        (if (is-some (map-get? makers-takers-nft-ids tx-sender)) 
            (begin 
                (map-set makers-takers-nft-ids tx-sender (unwrap! (as-max-len? (append (default-to (list) (map-get? makers-takers-nft-ids maker)) new-id) u1000) ERR_DATA_NOT_FOUND))
                ;; #[allow(unchecked_data)]
                (map-set makers-takers-nft-ids taker (unwrap! (as-max-len? (append (default-to (list) (map-get? makers-takers-nft-ids taker)) new-id) u1000) ERR_DATA_NOT_FOUND))
            )
            (begin
                (map-set makers-takers-nft-ids tx-sender (list new-id))
                ;; #[allow(unchecked_data)]
                (map-set makers-takers-nft-ids taker (list new-id))
            )
        )
        ;; #[allow(unchecked_data)]
        (map-set locked-nfts new-id {id: new-id, nft-token: (contract-of nft-token), nft-id: nft-id ,maker: tx-sender, taker: taker, expiry: expiry-days})
        ;; #[allow(unchecked_data)]
        (try! (contract-call? nft-token transfer nft-id maker (as-contract tx-sender)))
        (var-set last-nft-id new-id)
        (ok new-id)
    )
)

;; Function to claim-ft locked token by corresponding tx-sender
(define-public (claim-ft (ft-token <ft-trait>) (id uint)) 
    (let
        (
            (data (unwrap! (map-get? locked-fts id) ERR_DATA_NOT_FOUND))
            (maker (get maker data))
            (taker (get taker data))
            (contract-token (get ft-token data))
            (amount (get amount data))
            (expiry (get expiry data))
            (contract-address (as-contract tx-sender))
        )
        (asserts! (is-eq (contract-of ft-token) contract-token) ERR_FT_TOKEN_NOT_MATCH)
        (asserts! (is-some (map-get? locked-fts id)) ERR_DATA_NOT_FOUND)
        (asserts! (is-eq tx-sender taker) ERR_CLAIMER_ONLY)
        (asserts! (> block-height expiry ) ERR_UNLOCK_HEIGHT_NOT_REACHED)
        (var-set id-to-remove id)
        ;; #[allow(unchecked_data)]
        (try! (contract-call? ft-token transfer amount contract-address taker none))
        (map-set makers-takers-ft-ids maker (filter remove-ids (default-to (list) (map-get? makers-takers-ft-ids maker))))
        (map-set makers-takers-ft-ids tx-sender (filter remove-ids (default-to (list) (map-get? makers-takers-ft-ids taker))))
        (map-delete locked-fts id)
        (var-set id-to-remove u0)
        (ok id)
    )
)

;; Function to claim-nft locked token by corresponding tx-sender
(define-public (claim-nft (nft-token <nft-trait>) (id uint)) 
    (let
        (
            (data (unwrap! (map-get? locked-nfts id) ERR_DATA_NOT_FOUND))
            (maker (get maker data))
            (nft-id (get nft-id data))
            (contract-token (get nft-token data))
            (taker (get taker data))
            (expiry (get expiry data))
            (contract-address (as-contract tx-sender))
        )
        (asserts! (is-eq (contract-of nft-token) contract-token) ERR_FT_TOKEN_NOT_MATCH)
        (asserts! (is-some (map-get? locked-nfts id)) ERR_DATA_NOT_FOUND)
        (asserts! (is-eq tx-sender taker) ERR_CLAIMER_ONLY)
        (asserts! (> block-height expiry ) ERR_UNLOCK_HEIGHT_NOT_REACHED)
        (var-set id-to-remove id)
        ;; (try! (contract-call? .magic-beans transfer amount contract-address taker))
        ;; #[allow(unchecked_data)]
        (try! (contract-call? nft-token transfer nft-id contract-address taker))
        (map-set makers-takers-nft-ids maker (filter remove-ids (default-to (list) (map-get? makers-takers-nft-ids maker))))
        (map-set makers-takers-nft-ids tx-sender (filter remove-ids (default-to (list) (map-get? makers-takers-nft-ids taker))))
        (map-delete locked-nfts id)
        (var-set id-to-remove u0)
        (ok id)
    )
)

;; 1 (contract-call? .magic-beans mint u100000)
;; (contract-call? .ape mint)

;; 2 (contract-call? .vesting lock-ft 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5 u1000 u1)
;; (contract-call? .vesting lock-nft 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5 u1 u1)
;; 3 ::get_assets_maps

;; 4 (contract-call? .vesting get-ft-maker-list 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; 5 (contract-call? .vesting get-ft-maker-taker-detail-id u1)
;;(contract-call? .vesting get-nft-maker-taker-detail-id u1)

;; 6 ::set_tx_sender ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5

;; 7 (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.vesting get-ft-taker-list 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; 8 ::advance_chain_tip 200

;; 9 (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.vesting claim-ft u1)
;; (contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.vesting claim-nft u1)