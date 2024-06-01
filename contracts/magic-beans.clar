(impl-trait .sip010.sip010-ft-trait)
;; Fungible token
(define-fungible-token magic-beans)

;; Errors
(define-constant ERR_NO_AMOUNT_VALUE (err u102))

;; Function to read symbol of ft
(define-read-only (get-symbol)
  (ok "MAGIC")
)

;; Function to read name of ft
(define-read-only (get-name)
  (ok "magic-beans")
)

;; Function to get decimals of ft
(define-read-only (get-decimals)
  (ok u6)
)

;; Function to get uri of ft
(define-read-only (get-token-uri)
	(ok none)
)

;; Function to get total supply of ft
(define-read-only (get-total-supply)
	(ok (ft-get-supply magic-beans))
)

;; Mint function to mint tokens
(define-public (mint (amount uint))
  (begin
    (asserts! (> amount u0) ERR_NO_AMOUNT_VALUE)
    (ft-mint? magic-beans amount tx-sender)
  )
)

;; Function to transfer tokens
(define-public (transfer (amount uint) (maker principal) (taker principal) (memo (optional (buff 34))))
  (begin
    (asserts! (> amount u0) ERR_NO_AMOUNT_VALUE)
    ;; #[allow(unchecked_data)]
    (ft-transfer? magic-beans amount maker taker)
  )
)

;; Function to get token balance
(define-read-only (get-balance (who principal))
  (ok (ft-get-balance magic-beans who))
)