;; Staff Verification Contract
;; Confirms authorized personnel

(define-data-var admin principal tx-sender)

;; Map of staff members to their roles and status
(define-map staff-members
  { staff-id: principal }
  {
    name: (string-ascii 64),
    role: (string-ascii 32),
    store-id: (string-ascii 32),
    is-active: bool
  }
)

;; Map of role permissions
(define-map role-permissions
  { role: (string-ascii 32) }
  {
    can-open: bool,
    can-close: bool,
    is-manager: bool
  }
)

;; Add a new staff member
(define-public (register-staff
    (staff-id principal)
    (name (string-ascii 64))
    (role (string-ascii 32))
    (store-id (string-ascii 32)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (map-set staff-members
      { staff-id: staff-id }
      {
        name: name,
        role: role,
        store-id: store-id,
        is-active: true
      }))
  )
)

;; Deactivate a staff member
(define-public (deactivate-staff (staff-id principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (match (map-get? staff-members { staff-id: staff-id })
      staff (ok (map-set staff-members
                { staff-id: staff-id }
                (merge staff { is-active: false })))
      (err u404)
    )
  )
)

;; Define role permissions
(define-public (set-role-permissions
    (role (string-ascii 32))
    (can-open bool)
    (can-close bool)
    (is-manager bool))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (map-set role-permissions
      { role: role }
      {
        can-open: can-open,
        can-close: can-close,
        is-manager: is-manager
      }))
  )
)

;; Check if a staff member is authorized to open a store
(define-read-only (can-staff-open-store (staff-id principal) (store-id (string-ascii 32)))
  (match (map-get? staff-members { staff-id: staff-id })
    staff (and
            (get is-active staff)
            (is-eq (get store-id staff) store-id)
            (match (map-get? role-permissions { role: (get role staff) })
              permissions (get can-open permissions)
              false))
    false)
)

;; Check if a staff member is authorized to close a store
(define-read-only (can-staff-close-store (staff-id principal) (store-id (string-ascii 32)))
  (match (map-get? staff-members { staff-id: staff-id })
    staff (and
            (get is-active staff)
            (is-eq (get store-id staff) store-id)
            (match (map-get? role-permissions { role: (get role staff) })
              permissions (get can-close permissions)
              false))
    false)
)

;; Check if a staff member is a manager
(define-read-only (is-staff-manager (staff-id principal))
  (match (map-get? staff-members { staff-id: staff-id })
    staff (match (map-get? role-permissions { role: (get role staff) })
            permissions (get is-manager permissions)
            false)
    false)
)

;; Transfer admin rights
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
