(impl-trait .sip009.sip009-nft-trait)

(define-non-fungible-token ape uint)

(define-data-var last-token-id uint u0)

(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? ape id))
)

(define-read-only (get-token-uri (id uint))
    (ok none)
)

(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

(define-public (transfer (id uint) (sender principal) (receiver principal))
    (begin
        ;; #[allow(unchecked_data)]
        (try! (nft-transfer? ape id sender receiver))
        (ok true)
    )
)

(define-public (mint) 
    (let 
        (
             (id (+ (var-get last-token-id) u1))
        )
        (try! (nft-mint? ape id tx-sender))
        (var-set last-token-id id)
        (ok id)
    )
)