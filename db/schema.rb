# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_01_17_122501) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  execute 'CREATE SEQUENCE analisies_code_seq;'
  execute 'CREATE SEQUENCE samples_code_seq;'

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "analisies", force: :cascade do |t|
    t.bigint "sample_id"
    t.bigint "analisy_type_id"
    t.integer "code", default: -> { "((to_char((CURRENT_DATE)::timestamp with time zone, 'YY'::text) || lpad((nextval('analisies_code_seq'::regclass))::text, 5, '0'::text)))::integer" }, null: false
    t.integer "revision", default: 0, null: false
    t.datetime "reference_at"
    t.string "method"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analisy_type_id"], name: "index_analisies_on_analisy_type_id"
    t.index ["code"], name: "index_analisies_on_code", unique: true
    t.index ["reference_at"], name: "index_analisies_on_reference_at"
    t.index ["revision"], name: "index_analisies_on_revision"
    t.index ["sample_id", "analisy_type_id"], name: "index_analisies_on_sample_id_and_analisy_type_id"
    t.index ["sample_id"], name: "index_analisies_on_sample_id"
  end

  create_table "analisy_result_reports", force: :cascade do |t|
    t.bigint "analisy_result_id"
    t.bigint "report_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analisy_result_id", "report_id"], name: "index_analisy_result_reports_on_analisy_result_id_and_report_id"
    t.index ["analisy_result_id"], name: "index_analisy_result_reports_on_analisy_result_id"
    t.index ["report_id", "analisy_result_id"], name: "index_analisy_result_reports_on_report_id_and_analisy_result_id"
    t.index ["report_id"], name: "index_analisy_result_reports_on_report_id"
  end

  create_table "analisy_results", force: :cascade do |t|
    t.bigint "analisy_id", null: false
    t.bigint "nuclide_id", null: false
    t.decimal "result"
    t.bigint "result_unit_id"
    t.string "symbol", default: "", null: false
    t.decimal "indecision"
    t.bigint "indecision_unit_id"
    t.string "mcr"
    t.string "doc_rif_int"
    t.string "full_result", default: "", null: false
    t.string "full_result_with_nuclide", default: "", null: false
    t.boolean "absent", default: false, null: false
    t.text "absence_analysis", default: "", null: false
    t.boolean "active", default: true, null: false
    t.text "info"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["absent"], name: "index_analisy_results_on_absent"
    t.index ["active"], name: "index_analisy_results_on_active"
    t.index ["analisy_id", "nuclide_id", "active"], name: "index_analisy_results_on_analisy_id_and_nuclide_id_and_active", unique: true
    t.index ["analisy_id"], name: "index_analisy_results_on_analisy_id"
    t.index ["indecision"], name: "index_analisy_results_on_indecision"
    t.index ["indecision_unit_id"], name: "index_analisy_results_on_indecision_unit_id"
    t.index ["nuclide_id"], name: "index_analisy_results_on_nuclide_id"
    t.index ["result"], name: "index_analisy_results_on_result"
    t.index ["result_unit_id"], name: "index_analisy_results_on_result_unit_id"
  end

  create_table "analisy_types", force: :cascade do |t|
    t.bigint "instruction_id"
    t.citext "title", null: false
    t.text "body"
    t.boolean "radon", default: false, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_analisy_types_on_active"
    t.index ["instruction_id"], name: "index_analisy_types_on_instruction_id"
    t.index ["radon"], name: "index_analisy_types_on_radon"
    t.index ["title"], name: "index_analisy_types_on_title", unique: true
  end

  create_table "analisy_users", force: :cascade do |t|
    t.bigint "analisy_id", null: false
    t.bigint "user_id", null: false
    t.integer "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analisy_id", "user_id", "role"], name: "index_analisy_users_on_analisy_id_and_user_id_and_role", unique: true
    t.index ["analisy_id"], name: "index_analisy_users_on_analisy_id"
    t.index ["role"], name: "index_analisy_users_on_role"
    t.index ["user_id"], name: "index_analisy_users_on_user_id"
  end

  create_table "attachments", force: :cascade do |t|
    t.string "attachable_type"
    t.bigint "attachable_id"
    t.citext "title", default: "", null: false
    t.text "body", default: ""
    t.integer "category", default: 0, null: false
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attachable_type", "attachable_id"], name: "index_attachments_on_attachable_type_and_attachable_id"
    t.index ["body"], name: "index_attachments_on_body"
    t.index ["category"], name: "index_attachments_on_category"
    t.index ["title"], name: "index_attachments_on_title"
  end

  create_table "instructions", force: :cascade do |t|
    t.string "title", null: false
    t.text "body"
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_instructions_on_active"
    t.index ["title"], name: "index_instructions_on_title"
  end

  create_table "job_contacts", force: :cascade do |t|
    t.bigint "job_id"
    t.string "label", default: "", null: false
    t.text "note"
    t.boolean "priority", default: false, null: false
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id", "label"], name: "index_job_contacts_on_job_id_and_label", unique: true
    t.index ["job_id", "priority"], name: "index_job_contacts_on_job_id_and_priority", unique: true, order: { priority: :desc }
    t.index ["job_id"], name: "index_job_contacts_on_job_id"
  end

  create_table "job_roles", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "user_id", null: false
    t.boolean "manager", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id", "user_id"], name: "index_job_roles_on_job_id_and_user_id", unique: true
    t.index ["job_id"], name: "index_job_roles_on_job_id"
    t.index ["manager"], name: "index_job_roles_on_manager"
    t.index ["user_id"], name: "index_job_roles_on_user_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.bigint "chief_id", null: false
    t.string "code", default: "", null: false
    t.citext "title", default: "", null: false
    t.integer "version", default: 1, null: false
    t.integer "revision", default: 0, null: false
    t.string "template"
    t.text "body"
    t.date "open_at", null: false
    t.date "close_at"
    t.date "planned_closure_at"
    t.boolean "consolidated", default: false, null: false
    t.boolean "pa_support", default: false, null: false
    t.integer "n_samples", default: 0
    t.jsonb "metadata"
    t.integer "status", default: 1, null: false
    t.boolean "timetables_validated", default: false, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chief_id"], name: "index_jobs_on_chief_id"
    t.index ["close_at"], name: "index_jobs_on_close_at"
    t.index ["code"], name: "index_jobs_on_code"
    t.index ["consolidated"], name: "index_jobs_on_consolidated"
    t.index ["deleted"], name: "index_jobs_on_deleted"
    t.index ["n_samples"], name: "index_jobs_on_n_samples"
    t.index ["open_at", "title"], name: "index_jobs_on_open_at_and_title", order: { open_at: :desc }
    t.index ["open_at"], name: "index_jobs_on_open_at"
    t.index ["pa_support"], name: "index_jobs_on_pa_support"
    t.index ["planned_closure_at"], name: "index_jobs_on_planned_closure_at"
    t.index ["revision"], name: "index_jobs_on_revision"
    t.index ["status"], name: "index_jobs_on_status"
    t.index ["timetables_validated"], name: "index_jobs_on_timetables_validated"
    t.index ["title"], name: "index_jobs_on_title"
    t.index ["version"], name: "index_jobs_on_version"
  end

  create_table "logs", force: :cascade do |t|
    t.string "author", null: false
    t.bigint "job_id"
    t.string "loggable_type"
    t.bigint "loggable_id"
    t.string "action", default: "", null: false
    t.text "body", default: "", null: false
    t.jsonb "field", default: "{}"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author"], name: "index_logs_on_author"
    t.index ["created_at"], name: "index_logs_on_created_at"
    t.index ["job_id"], name: "index_logs_on_job_id"
    t.index ["loggable_type", "loggable_id"], name: "index_logs_on_loggable_type_and_loggable_id"
  end

  create_table "matrix_types", force: :cascade do |t|
    t.integer "pid"
    t.citext "title", null: false
    t.text "body"
    t.integer "radia"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_matrix_types_on_active"
    t.index ["pid", "title"], name: "index_matrix_types_on_pid_and_title", unique: true
    t.index ["radia"], name: "index_matrix_types_on_radia"
    t.index ["title"], name: "index_matrix_types_on_title"
  end

  create_table "nuclides", force: :cascade do |t|
    t.citext "title", default: "", null: false
    t.text "body"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_nuclides_on_active"
    t.index ["title"], name: "index_nuclides_on_title"
  end

  create_table "reports", force: :cascade do |t|
    t.string "code", default: -> { "to_char(CURRENT_TIMESTAMP, 'YYMMDDMIHH24'::text)" }, null: false
    t.integer "report_type", default: 0, null: false
    t.integer "job_id", null: false
    t.integer "analisy_id"
    t.datetime "cancelled_at"
    t.text "cancellation_reason", default: "", null: false
    t.string "file_file_name", null: false
    t.string "file_content_type", null: false
    t.integer "file_file_size", null: false
    t.datetime "file_updated_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analisy_id"], name: "index_reports_on_analisy_id"
    t.index ["code"], name: "index_reports_on_code"
    t.index ["job_id"], name: "index_reports_on_job_id"
    t.index ["report_type"], name: "index_reports_on_report_type"
  end

  create_table "samples", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "type_matrix_id"
    t.integer "code", default: -> { "((to_char((CURRENT_DATE)::timestamp with time zone, 'YY'::text) || lpad((nextval('samples_code_seq'::regclass))::text, 5, '0'::text)))::integer" }, null: false
    t.string "device", default: "", null: false
    t.string "lab_code"
    t.string "client_code", default: "", null: false
    t.float "latitude"
    t.float "longitude"
    t.integer "epsg", default: 4326, null: false
    t.datetime "start_at"
    t.datetime "stop_at"
    t.date "accepted_at", default: -> { "CURRENT_DATE" }, null: false
    t.text "report"
    t.string "conservation"
    t.text "body"
    t.string "created_by", default: "System", null: false
    t.string "updated_by", default: "System", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accepted_at"], name: "index_samples_on_accepted_at"
    t.index ["client_code"], name: "index_samples_on_client_code"
    t.index ["code"], name: "index_samples_on_code", unique: true
    t.index ["created_by"], name: "index_samples_on_created_by"
    t.index ["device"], name: "index_samples_on_device"
    t.index ["epsg"], name: "index_samples_on_epsg"
    t.index ["job_id", "created_at"], name: "index_samples_on_job_id_and_created_at"
    t.index ["job_id"], name: "index_samples_on_job_id"
    t.index ["lab_code"], name: "index_samples_on_lab_code"
    t.index ["latitude", "longitude"], name: "index_samples_on_latitude_and_longitude"
    t.index ["latitude"], name: "index_samples_on_latitude"
    t.index ["longitude"], name: "index_samples_on_longitude"
    t.index ["start_at"], name: "index_samples_on_start_at"
    t.index ["stop_at"], name: "index_samples_on_stop_at"
    t.index ["type_matrix_id"], name: "index_samples_on_type_matrix_id"
    t.index ["updated_by"], name: "index_samples_on_updated_by"
  end

  create_table "timetables", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.integer "parent_id"
    t.citext "title", default: "", null: false
    t.text "body", default: "", null: false
    t.date "start_at", null: false
    t.date "stop_at", null: false
    t.integer "days", null: false
    t.float "progress", default: 0.0, null: false
    t.text "products", default: "", null: false
    t.date "execute_at"
    t.boolean "restrict", default: false, null: false
    t.boolean "important", default: false, null: false
    t.boolean "closed", default: false, null: false
    t.integer "sortorder"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["closed"], name: "index_timetables_on_closed"
    t.index ["color"], name: "index_timetables_on_color"
    t.index ["days"], name: "index_timetables_on_days"
    t.index ["execute_at"], name: "index_timetables_on_execute_at"
    t.index ["important"], name: "index_timetables_on_important"
    t.index ["job_id", "title"], name: "index_timetables_on_job_id_and_title", unique: true
    t.index ["job_id"], name: "index_timetables_on_job_id"
    t.index ["parent_id", "id"], name: "index_timetables_on_parent_id_and_id", unique: true
    t.index ["parent_id"], name: "index_timetables_on_parent_id"
    t.index ["progress"], name: "index_timetables_on_progress"
    t.index ["restrict"], name: "index_timetables_on_restrict"
    t.index ["sortorder"], name: "index_timetables_on_sortorder"
    t.index ["start_at"], name: "index_timetables_on_start_at"
    t.index ["stop_at"], name: "index_timetables_on_stop_at"
    t.index ["title"], name: "index_timetables_on_title"
  end

  create_table "units", force: :cascade do |t|
    t.citext "title", null: false
    t.text "body"
    t.citext "html", default: ""
    t.citext "report", default: ""
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_units_on_active"
    t.index ["title"], name: "index_units_on_title"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "label", default: ""
    t.string "email", default: ""
    t.string "sex", default: ""
    t.boolean "supervisor", default: false
    t.boolean "admin", default: false
    t.boolean "technic", default: false
    t.boolean "headtest", default: false
    t.boolean "chief", default: false
    t.boolean "external", default: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin"], name: "index_users_on_admin"
    t.index ["chief"], name: "index_users_on_chief"
    t.index ["email"], name: "index_users_on_email"
    t.index ["external"], name: "index_users_on_external"
    t.index ["headtest"], name: "index_users_on_headtest"
    t.index ["label"], name: "index_users_on_label"
    t.index ["sex"], name: "index_users_on_sex"
    t.index ["supervisor"], name: "index_users_on_supervisor"
    t.index ["technic"], name: "index_users_on_technic"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "analisies", "analisy_types", on_delete: :cascade
  add_foreign_key "analisies", "samples", on_delete: :cascade
  add_foreign_key "analisy_result_reports", "analisy_results", on_update: :cascade, on_delete: :cascade
  add_foreign_key "analisy_result_reports", "reports", on_update: :cascade, on_delete: :restrict
  add_foreign_key "analisy_results", "analisies", on_update: :cascade, on_delete: :cascade
  add_foreign_key "analisy_results", "nuclides", on_update: :cascade, on_delete: :restrict
  add_foreign_key "analisy_results", "units", column: "indecision_unit_id", on_update: :cascade, on_delete: :restrict
  add_foreign_key "analisy_results", "units", column: "result_unit_id", on_update: :cascade, on_delete: :restrict
  add_foreign_key "analisy_types", "instructions", on_delete: :nullify
  add_foreign_key "analisy_users", "analisies", on_delete: :cascade
  add_foreign_key "analisy_users", "users", on_delete: :restrict
  add_foreign_key "job_contacts", "jobs"
  add_foreign_key "job_roles", "jobs", on_delete: :cascade
  add_foreign_key "job_roles", "users", on_delete: :restrict
  add_foreign_key "jobs", "users", column: "chief_id", on_delete: :restrict
  add_foreign_key "logs", "jobs"
  add_foreign_key "matrix_types", "matrix_types", column: "pid", on_update: :cascade, on_delete: :restrict
  add_foreign_key "reports", "analisies", on_update: :cascade, on_delete: :nullify
  add_foreign_key "reports", "jobs", on_update: :restrict, on_delete: :restrict
  add_foreign_key "samples", "jobs", on_delete: :cascade
  add_foreign_key "samples", "matrix_types", column: "type_matrix_id", on_update: :cascade, on_delete: :restrict
  add_foreign_key "timetables", "jobs", on_delete: :cascade
  add_foreign_key "timetables", "timetables", column: "parent_id", on_delete: :nullify
end
