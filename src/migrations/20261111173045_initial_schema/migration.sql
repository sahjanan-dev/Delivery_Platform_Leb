-- CreateEnum
CREATE TYPE "audit_outcome" AS ENUM ('ok', 'denied', 'failed');

-- CreateEnum
CREATE TYPE "business_category" AS ENUM ('online_shop', 'supermarket', 'fruit_vegetables', 'cosmetics', 'fashion', 'phones_electronics', 'optics', 'tools_hardware', 'sanitary_ware', 'textiles', 'flowers_gifts', 'car_rental', 'industry', 'other');

-- CreateEnum
CREATE TYPE "business_status" AS ENUM ('active', 'inactive', 'prospect');

-- CreateEnum
CREATE TYPE "business_type" AS ENUM ('shop', 'orders');

-- CreateEnum
CREATE TYPE "cancel_reason" AS ENUM ('client_asked', 'client_unreachable', 'duplicate', 'wrong_details', 'no_rider', 'other', 'client_declined');

-- CreateEnum
CREATE TYPE "cash_direction" AS ENUM ('from_rider', 'to_rider');

-- CreateEnum
CREATE TYPE "client_source" AS ENUM ('whatsapp', 'instagram', 'facebook', 'tiktok', 'website', 'indrive', 'through_business', 'referral', 'other');

-- CreateEnum
CREATE TYPE "client_status" AS ENUM ('active', 'inactive', 'do_not_deliver', 'blocked');

-- CreateEnum
CREATE TYPE "cod_policy" AS ENUM ('yes', 'no', 'sometimes');

-- CreateEnum
CREATE TYPE "conversation_mode" AS ENUM ('bot', 'human');

-- CreateEnum
CREATE TYPE "delivery_time" AS ENUM ('morning', 'afternoon', 'evening', 'any');

-- CreateEnum
CREATE TYPE "gender" AS ENUM ('female', 'male');

-- CreateEnum
CREATE TYPE "import_issue" AS ENUM ('no_name', 'location_unknown', 'zone_unclear', 'unusual_number', 'duplicate_phone');

-- CreateEnum
CREATE TYPE "language" AS ENUM ('ar', 'en', 'fr');

-- CreateEnum
CREATE TYPE "order_status" AS ENUM ('quote', 'new', 'assigned', 'picked_up', 'delivered', 'failed', 'cancelled');

-- CreateEnum
CREATE TYPE "parcel_size" AS ENUM ('S', 'M', 'L');

-- CreateEnum
CREATE TYPE "paused_by" AS ENUM ('bot', 'staff');

-- CreateEnum
CREATE TYPE "payment_method" AS ENUM ('cod_usd', 'cod_lbp', 'whish', 'omt', 'card', 'bank_transfer');

-- CreateEnum
CREATE TYPE "phone_kind" AS ENUM ('mobile', 'landline', 'international', 'unverified');

-- CreateEnum
CREATE TYPE "proof_kind" AS ENUM ('delivered', 'failed');

-- CreateEnum
CREATE TYPE "service_type" AS ENUM ('package', 'errand');

-- CreateEnum
CREATE TYPE "settlement_frequency" AS ENUM ('daily', 'weekly', 'biweekly', 'monthly');

-- CreateEnum
CREATE TYPE "settlement_method" AS ENUM ('cash', 'whish', 'omt', 'bank_transfer');

-- CreateEnum
CREATE TYPE "shift_ended_by" AS ENUM ('rider', 'staff');

-- CreateTable
CREATE TABLE "verifications" (
    "id" TEXT NOT NULL,
    "identifier" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "verifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "zones" (
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "geom" geometry(MultiPolygon,4326) NOT NULL,

    CONSTRAINT "zones_pkey" PRIMARY KEY ("code")
);

-- CreateTable
CREATE TABLE "areas" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "district" TEXT NOT NULL,
    "governorate" TEXT NOT NULL,
    "zone" TEXT,

    CONSTRAINT "areas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "addresses" (
    "id" SERIAL NOT NULL,
    "client_id" INTEGER NOT NULL,
    "lat" DOUBLE PRECISION NOT NULL,
    "lng" DOUBLE PRECISION NOT NULL,
    "zone" TEXT,
    "place_name" TEXT,
    "details" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_used_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "label" TEXT,
    "building" TEXT,
    "floor" TEXT,
    "apartment" TEXT,
    "landmark" TEXT,
    "instructions" TEXT,

    CONSTRAINT "addresses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "clients" (
    "id" SERIAL NOT NULL,
    "wa_id" TEXT NOT NULL,
    "name" TEXT,
    "profile_name" TEXT,
    "source" "client_source",
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "title" TEXT,
    "first_name" TEXT,
    "last_name" TEXT,
    "gender" "gender",
    "language" "language",
    "status" "client_status" NOT NULL DEFAULT 'active',
    "area_id" INTEGER,
    "preferred_time" "delivery_time",
    "preferred_payment" "payment_method",
    "marketing_consent" BOOLEAN,
    "marketing_consent_at" TIMESTAMPTZ(6),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "name_confirmed_at" TIMESTAMPTZ(6),
    "erased_at" TIMESTAMPTZ(6),

    CONSTRAINT "clients_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "client_phones" (
    "id" SERIAL NOT NULL,
    "client_id" INTEGER NOT NULL,
    "phone" TEXT NOT NULL,
    "kind" "phone_kind" NOT NULL,
    "is_primary" BOOLEAN NOT NULL DEFAULT false,
    "label" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "client_phones_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "conversations" (
    "wa_id" TEXT NOT NULL,
    "mode" "conversation_mode" NOT NULL DEFAULT 'bot',
    "human_until" TIMESTAMPTZ(6),
    "state" TEXT NOT NULL DEFAULT 'idle',
    "draft" JSONB NOT NULL DEFAULT '{}',
    "last_inbound_at" TIMESTAMPTZ(6),
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "paused_by" "paused_by",

    CONSTRAINT "conversations_pkey" PRIMARY KEY ("wa_id")
);

-- CreateTable
CREATE TABLE "businesses" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "type" "business_type" NOT NULL,
    "category" "business_category",
    "status" "business_status" NOT NULL DEFAULT 'active',
    "area_id" INTEGER,
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "businesses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "business_contacts" (
    "id" SERIAL NOT NULL,
    "business_id" INTEGER NOT NULL,
    "name" TEXT,
    "role" TEXT,
    "phone" TEXT NOT NULL,
    "phone_kind" "phone_kind" NOT NULL,
    "is_primary" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "business_contacts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "business_locations" (
    "id" SERIAL NOT NULL,
    "business_id" INTEGER NOT NULL,
    "label" TEXT,
    "lat" DOUBLE PRECISION,
    "lng" DOUBLE PRECISION,
    "zone" TEXT,
    "area_id" INTEGER,
    "building" TEXT,
    "floor" TEXT,
    "landmark" TEXT,
    "opening_hours" TEXT,
    "pickup_window" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived_at" TIMESTAMPTZ(6),

    CONSTRAINT "business_locations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "business_members" (
    "user_id" TEXT NOT NULL,
    "business_id" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "business_members_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "business_terms" (
    "business_id" INTEGER NOT NULL,
    "rate_per_order_usd" DECIMAL(8,2),
    "collects_cod" "cod_policy",
    "settlement_frequency" "settlement_frequency",
    "settlement_method" "settlement_method",
    "started_on" DATE,
    "expected_orders_per_week" INTEGER,
    "typical_parcel_size" "parcel_size",
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "business_terms_pkey" PRIMARY KEY ("business_id")
);

-- CreateTable
CREATE TABLE "order_batches" (
    "id" SERIAL NOT NULL,
    "business_id" INTEGER NOT NULL,
    "created_by_user_id" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "idempotency_key" TEXT,

    CONSTRAINT "order_batches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "orders" (
    "id" SERIAL NOT NULL,
    "client_id" INTEGER,
    "service" "service_type" NOT NULL,
    "status" "order_status" NOT NULL DEFAULT 'new',
    "pickup_lat" DOUBLE PRECISION,
    "pickup_lng" DOUBLE PRECISION,
    "pickup_zone" TEXT,
    "pickup_details" TEXT,
    "dropoff_lat" DOUBLE PRECISION,
    "dropoff_lng" DOUBLE PRECISION,
    "dropoff_zone" TEXT,
    "dropoff_details" TEXT,
    "items" TEXT,
    "size" "parcel_size",
    "price_usd" DECIMAL(8,2),
    "rider_id" INTEGER,
    "fail_reason" TEXT,
    "rating" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "assigned_at" TIMESTAMPTZ(6),
    "picked_up_at" TIMESTAMPTZ(6),
    "finished_at" TIMESTAMPTZ(6),
    "recipient_name" TEXT,
    "recipient_phone" TEXT,
    "business_id" INTEGER,
    "business_location_id" INTEGER,
    "batch_id" INTEGER,
    "dropoff_area_id" INTEGER,
    "cod_usd" DECIMAL(10,2),
    "notes" TEXT,
    "settlement_id" INTEGER,
    "cod_lbp" BIGINT,
    "retry_of_order_id" INTEGER,
    "collected_usd" DECIMAL(10,2),
    "collected_lbp" BIGINT,
    "rider_pay_percent" INTEGER,
    "rider_pay_usd" DECIMAL(8,2),
    "step_changed_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "cancel_reason" "cancel_reason",
    "cancel_note" TEXT,
    "rider_link_key" TEXT NOT NULL,

    CONSTRAINT "orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_events" (
    "id" SERIAL NOT NULL,
    "order_id" INTEGER NOT NULL,
    "type" TEXT NOT NULL,
    "data" JSONB,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actor_user_id" TEXT,

    CONSTRAINT "order_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_forms" (
    "id" SERIAL NOT NULL,
    "wa_id" TEXT NOT NULL,
    "service" "service_type" NOT NULL,
    "language" "language" NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "submitted_at" TIMESTAMPTZ(6),
    "token_hash" TEXT NOT NULL,

    CONSTRAINT "order_forms_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "riders" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "telegram_chat_id" BIGINT,
    "telegram_linked_at" TIMESTAMPTZ(6),
    "language" "language" NOT NULL DEFAULT 'ar',
    "pay_percent" INTEGER NOT NULL DEFAULT 80,

    CONSTRAINT "riders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rider_telegram_links" (
    "rider_id" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "used_at" TIMESTAMPTZ(6),
    "code_hash" TEXT NOT NULL,

    CONSTRAINT "rider_telegram_links_pkey" PRIMARY KEY ("code_hash")
);

-- CreateTable
CREATE TABLE "rider_shifts" (
    "id" SERIAL NOT NULL,
    "rider_id" INTEGER NOT NULL,
    "started_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "start_lat" DOUBLE PRECISION NOT NULL,
    "start_lng" DOUBLE PRECISION NOT NULL,
    "ended_at" TIMESTAMPTZ(6),
    "end_lat" DOUBLE PRECISION,
    "end_lng" DOUBLE PRECISION,
    "ended_by" "shift_ended_by",
    "ended_by_user_id" TEXT,
    "live_shared_at" TIMESTAMPTZ(6),
    "live_until" TIMESTAMPTZ(6),
    "last_lat" DOUBLE PRECISION,
    "last_lng" DOUBLE PRECISION,
    "last_accuracy_m" DOUBLE PRECISION,
    "last_at" TIMESTAMPTZ(6),

    CONSTRAINT "rider_shifts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rider_locations" (
    "id" BIGSERIAL NOT NULL,
    "rider_id" INTEGER NOT NULL,
    "shift_id" INTEGER NOT NULL,
    "lat" DOUBLE PRECISION NOT NULL,
    "lng" DOUBLE PRECISION NOT NULL,
    "accuracy_m" DOUBLE PRECISION,
    "recorded_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "rider_locations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "delivery_proofs" (
    "id" SERIAL NOT NULL,
    "order_id" INTEGER NOT NULL,
    "rider_id" INTEGER,
    "kind" "proof_kind" NOT NULL,
    "file" TEXT,
    "sha256" TEXT NOT NULL,
    "bytes" INTEGER NOT NULL,
    "taken_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "device_time" TIMESTAMPTZ(6),
    "lat" DOUBLE PRECISION NOT NULL,
    "lng" DOUBLE PRECISION NOT NULL,
    "accuracy_m" DOUBLE PRECISION,
    "distance_m" INTEGER,
    "user_agent" TEXT,
    "file_removed_at" TIMESTAMPTZ(6),

    CONSTRAINT "delivery_proofs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "business_settlements" (
    "id" SERIAL NOT NULL,
    "business_id" INTEGER NOT NULL,
    "cod_usd" DECIMAL(12,2) NOT NULL,
    "fees_usd" DECIMAL(12,2) NOT NULL,
    "net_usd" DECIMAL(12,2) NOT NULL,
    "method" "settlement_method",
    "note" TEXT,
    "created_by_user_id" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "cod_lbp" BIGINT NOT NULL DEFAULT 0,
    "voided_at" TIMESTAMPTZ(6),
    "voided_by_user_id" TEXT,

    CONSTRAINT "business_settlements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rider_cash_movements" (
    "id" SERIAL NOT NULL,
    "rider_id" INTEGER NOT NULL,
    "direction" "cash_direction" NOT NULL,
    "usd" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "lbp" BIGINT NOT NULL DEFAULT 0,
    "note" TEXT,
    "recorded_by_user_id" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "voided_at" TIMESTAMPTZ(6),
    "voided_by_user_id" TEXT,
    "idempotency_key" TEXT,

    CONSTRAINT "rider_cash_movements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_log" (
    "id" BIGSERIAL NOT NULL,
    "actor_user_id" TEXT,
    "actor_name" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "resource_type" TEXT NOT NULL,
    "resource_id" TEXT,
    "before" JSONB,
    "after" JSONB,
    "outcome" "audit_outcome" NOT NULL DEFAULT 'ok',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_log_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "import_records" (
    "id" SERIAL NOT NULL,
    "source" TEXT NOT NULL,
    "legacy_id" TEXT NOT NULL,
    "client_id" INTEGER,
    "business_id" INTEGER,
    "saved_as" TEXT,
    "phone_edited_on" DATE,
    "issues" "import_issue"[] DEFAULT ARRAY[]::"import_issue"[],
    "merged_saved_as" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "import_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "wa_messages" (
    "id" SERIAL NOT NULL,
    "wamid" TEXT NOT NULL,
    "direction" TEXT NOT NULL,
    "wa_id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "status" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processed_at" TIMESTAMPTZ(6),

    CONSTRAINT "wa_messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tg_updates" (
    "update_id" BIGINT NOT NULL,
    "payload" JSONB NOT NULL,
    "received_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processed_at" TIMESTAMPTZ(6),

    CONSTRAINT "tg_updates_pkey" PRIMARY KEY ("update_id")
);

-- CreateTable
CREATE TABLE "tg_order_messages" (
    "id" SERIAL NOT NULL,
    "order_id" INTEGER NOT NULL,
    "rider_id" INTEGER NOT NULL,
    "chat_id" BIGINT NOT NULL,
    "message_id" BIGINT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tg_order_messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "staff_telegram" (
    "user_id" TEXT NOT NULL,
    "chat_id" BIGINT NOT NULL,
    "linked_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "staff_telegram_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "staff_telegram_links" (
    "user_id" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "used_at" TIMESTAMPTZ(6),
    "code_hash" TEXT NOT NULL,

    CONSTRAINT "staff_telegram_links_pkey" PRIMARY KEY ("code_hash")
);

-- CreateTable
CREATE TABLE "staff_shifts" (
    "id" SERIAL NOT NULL,
    "user_id" TEXT NOT NULL,
    "started_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ended_at" TIMESTAMPTZ(6),
    "ended_by_user_id" TEXT,
    "reminded_at" TIMESTAMPTZ(6),

    CONSTRAINT "staff_shifts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "alert_log" (
    "key" TEXT NOT NULL,
    "sent_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "alert_log_pkey" PRIMARY KEY ("key")
);

-- CreateTable
CREATE TABLE "proof_files_to_remove" (
    "file" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "proof_files_to_remove_pkey" PRIMARY KEY ("file")
);

-- CreateIndex
CREATE INDEX "verifications_identifier_idx" ON "verifications"("identifier");

-- CreateIndex
CREATE UNIQUE INDEX "areas_name_key" ON "areas"("name");

-- CreateIndex
CREATE UNIQUE INDEX "clients_wa_id_key" ON "clients"("wa_id");

-- CreateIndex
CREATE INDEX "clients_area_idx" ON "clients"("area_id");

-- CreateIndex
CREATE UNIQUE INDEX "client_phones_phone_uq" ON "client_phones"("phone");

-- CreateIndex
CREATE INDEX "client_phones_client_idx" ON "client_phones"("client_id");

-- CreateIndex
CREATE INDEX "business_contacts_business_idx" ON "business_contacts"("business_id");

-- CreateIndex
CREATE INDEX "business_contacts_phone_idx" ON "business_contacts"("phone");

-- CreateIndex
CREATE INDEX "business_locations_business_idx" ON "business_locations"("business_id");

-- CreateIndex
CREATE UNIQUE INDEX "business_locations_id_business_uq" ON "business_locations"("id", "business_id");

-- CreateIndex
CREATE INDEX "business_members_business_idx" ON "business_members"("business_id");

-- CreateIndex
CREATE INDEX "order_batches_business_idx" ON "order_batches"("business_id", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "order_batches_id_business_uq" ON "order_batches"("id", "business_id");

-- CreateIndex
CREATE UNIQUE INDEX "order_batches_idempotency_uq" ON "order_batches"("business_id", "idempotency_key");

-- CreateIndex
CREATE UNIQUE INDEX "orders_retry_of_uq" ON "orders"("retry_of_order_id");

-- CreateIndex
CREATE UNIQUE INDEX "orders_rider_link_key_key" ON "orders"("rider_link_key");

-- CreateIndex
CREATE INDEX "orders_batch_idx" ON "orders"("batch_id");

-- CreateIndex
CREATE INDEX "orders_business_idx" ON "orders"("business_id", "created_at");

-- CreateIndex
CREATE INDEX "orders_client_idx" ON "orders"("client_id");

-- CreateIndex
CREATE INDEX "orders_rider_idx" ON "orders"("rider_id", "status");

-- CreateIndex
CREATE INDEX "orders_status_idx" ON "orders"("status", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "orders_id_business_uq" ON "orders"("id", "business_id");

-- CreateIndex
CREATE UNIQUE INDEX "orders_id_client_uq" ON "orders"("id", "client_id");

-- CreateIndex
CREATE INDEX "order_events_order_idx" ON "order_events"("order_id", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "order_forms_token_hash_key" ON "order_forms"("token_hash");

-- CreateIndex
CREATE INDEX "order_forms_wa_id_idx" ON "order_forms"("wa_id", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "riders_phone_key" ON "riders"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "riders_telegram_chat_id_key" ON "riders"("telegram_chat_id");

-- CreateIndex
CREATE INDEX "rider_shifts_rider_idx" ON "rider_shifts"("rider_id", "started_at");

-- CreateIndex
CREATE UNIQUE INDEX "rider_shifts_id_rider_uq" ON "rider_shifts"("id", "rider_id");

-- CreateIndex
CREATE INDEX "rider_locations_recorded_idx" ON "rider_locations"("recorded_at");

-- CreateIndex
CREATE INDEX "rider_locations_shift_idx" ON "rider_locations"("shift_id", "recorded_at");

-- CreateIndex
CREATE UNIQUE INDEX "delivery_proofs_order_id_key" ON "delivery_proofs"("order_id");

-- CreateIndex
CREATE INDEX "business_settlements_business_idx" ON "business_settlements"("business_id", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "business_settlements_id_business_uq" ON "business_settlements"("id", "business_id");

-- CreateIndex
CREATE UNIQUE INDEX "rider_cash_movements_idempotency_key_key" ON "rider_cash_movements"("idempotency_key");

-- CreateIndex
CREATE INDEX "rider_cash_movements_rider_idx" ON "rider_cash_movements"("rider_id", "created_at");

-- CreateIndex
CREATE INDEX "audit_log_actor_idx" ON "audit_log"("actor_user_id", "created_at");

-- CreateIndex
CREATE INDEX "audit_log_resource_idx" ON "audit_log"("resource_type", "resource_id", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "import_records_legacy_id_key" ON "import_records"("legacy_id");

-- CreateIndex
CREATE INDEX "import_records_business_idx" ON "import_records"("business_id");

-- CreateIndex
CREATE INDEX "import_records_client_idx" ON "import_records"("client_id");

-- CreateIndex
CREATE UNIQUE INDEX "wa_messages_wamid_key" ON "wa_messages"("wamid");

-- CreateIndex
CREATE INDEX "wa_messages_wa_id_idx" ON "wa_messages"("wa_id", "created_at");

-- CreateIndex
CREATE INDEX "tg_order_messages_order_idx" ON "tg_order_messages"("order_id");

-- CreateIndex
CREATE UNIQUE INDEX "staff_telegram_chat_id_key" ON "staff_telegram"("chat_id");

-- CreateIndex
CREATE INDEX "staff_shifts_user_idx" ON "staff_shifts"("user_id", "started_at");

-- AddForeignKey
ALTER TABLE "client_phones" ADD CONSTRAINT "client_phones_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "clients"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "business_contacts" ADD CONSTRAINT "business_contacts_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "business_locations" ADD CONSTRAINT "business_locations_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "business_members" ADD CONSTRAINT "business_members_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "business_members" ADD CONSTRAINT "business_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "business_terms" ADD CONSTRAINT "business_terms_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;
