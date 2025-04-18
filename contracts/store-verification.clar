;; Store Verification Contract
;; Validates legitimate retail locations

(define-data-var admin principal tx-sender)

;; Map of verified store IDs to their status (true = verified)
(define-map verified-stores
  { store-id: (string-ascii 32) }
  { verified: bool, location: (string-ascii 100) }
)

;; Add a new store to the verified list
(define-public (register-store (store-id (string-ascii 32)) (location (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (map-set verified-stores { store-id: store-id } { verified: true, location: location }))
  )
)

;; Remove a store from the verified list
(define-public (deregister-store (store-id (string-ascii 32)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (map-set verified-stores { store-id: store-id } { verified: false, location: "" }))
  )
)

;; Check if a store is verified
(define-read-only (is-store-verified (store-id (string-ascii 32)))
  (default-to false (get verified (map-get? verified-stores { store-id: store-id })))
)

;; Get store location
(define-read-only (get-store-location (store-id (string-ascii 32)))
  (default-to "" (get location (map-get? verified-stores { store-id: store-id })))
)

;; Transfer admin rights
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
