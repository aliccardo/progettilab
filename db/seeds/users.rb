puts 'Utenti'
User.create(username: 'system', label: 'System', email: '', sex: '', supervisor: false, admin: false, technic: true, chief: false, external: false, headtest: false, sign_in_count: 0, created_at: Time.now, updated_at: Time.now)
User.create(username: 'tecnico1', label: 'Tecnico1', email: '', sex: '', supervisor: false, admin: false, technic: true, chief: false, external: false, headtest: false, sign_in_count: 0, created_at: Time.now, updated_at: Time.now)
User.create(username: 'tecnico2', label: 'Tecnico2', email: '', sex: '', supervisor: false, admin: false, technic: true, chief: false, external: false, headtest: false, sign_in_count: 0, created_at: Time.now, updated_at: Time.now)
User.create(username: 'utente1', label: 'Utente1', email: '', sex: '', supervisor: false, admin: false, technic: false, chief: false, external: false, headtest: false, sign_in_count: 0, created_at: Time.now, updated_at: Time.now)
User.create(username: 'utente2', label: 'Utente2', email: '', sex: '', supervisor: false, admin: false, technic: false, chief: false, external: false, headtest: false, sign_in_count: 0, created_at: Time.now, updated_at: Time.now)
User.create(username: 'esterno1', label: 'Esterno1', email: '', sex: '', supervisor: true, admin: true, chief: false, external: true, headtest: false, sign_in_count: 0, created_at: Time.now, updated_at: Time.now)
User.create(username: 'capotest1', label: 'Capotest1', email: '', sex: '', supervisor: true, admin: true, chief: false, external: false, headtest: true, sign_in_count: 0, created_at: Time.now, updated_at: Time.now)
User.create(username: 'supervisore1', label: 'Supervisore1', email: '', sex: '', supervisor: true, admin: false, chief: false, external: false, headtest: false, sign_in_count: 0, created_at: Time.now, updated_at: Time.now)
User.create(username: 'capo1', label: 'Capo1', email: '', sex: '', supervisor: true, admin: false, chief: true, external: false, headtest: false, sign_in_count: 0, created_at: Time.now, updated_at: Time.now)
User.create(username: 'amministratore', label: 'Amministratore', email: '', sex: '', supervisor: true, admin: true, chief: false, external: false, headtest: false, sign_in_count: 0, created_at: Time.now, updated_at: Time.now)
