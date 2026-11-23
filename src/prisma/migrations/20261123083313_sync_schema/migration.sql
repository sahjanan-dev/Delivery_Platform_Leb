/*
  Warnings:

  - You are about to drop the column `instructions` on the `addresses` table. All the data in the column will be lost.
  - You are about to drop the column `place_name` on the `addresses` table. All the data in the column will be lost.
  - You are about to alter the column `lat` on the `addresses` table. The data in that column could be lost. The data in that column will be cast from `DoublePrecision` to `Decimal(9,6)`.
  - You are about to alter the column `lng` on the `addresses` table. The data in that column could be lost. The data in that column will be cast from `DoublePrecision` to `Decimal(9,6)`.
  - You are about to alter the column `lat` on the `business_locations` table. The data in that column could be lost. The data in that column will be cast from `DoublePrecision` to `Decimal(9,6)`.
  - You are about to alter the column `lng` on the `business_locations` table. The data in that column could be lost. The data in that column will be cast from `DoublePrecision` to `Decimal(9,6)`.
  - You are about to drop the column `first_name` on the `clients` table. All the data in the column will be lost.
  - You are about to drop the column `last_name` on the `clients` table. All the data in the column will be lost.
  - The primary key for the `conversations` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `wa_id` on the `conversations` table. All the data in the column will be lost.
  - You are about to drop the column `wa_id` on the `order_forms` table. All the data in the column will be lost.
  - Added the required column `role` to the `User` table without a default value. This is not possible if the table is not empty.
  - Added the required column `centroid` to the `areas` table without a default value. This is not possible if the table is not empty.
  - Added the required column `client_id` to the `conversations` table without a default value. This is not possible if the table is not empty.
  - Added the required column `to_status` to the `order_events` table without a default value. This is not possible if the table is not empty.
  - Added the required column `client_id` to the `order_forms` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "Role" AS ENUM ('ADMIN', 'DISPATCHER', 'BUSINESS');

-- CreateEnum
CREATE TYPE "ActorType" AS ENUM ('user', 'rider', 'customer');

-- DropIndex
DROP INDEX "order_forms_wa_id_idx";

-- AlterTable
ALTER TABLE "User" DROP COLUMN "role",
ADD COLUMN     "role" "Role" NOT NULL;

-- AlterTable
ALTER TABLE "addresses" DROP COLUMN "instructions",
DROP COLUMN "place_name",
ADD COLUMN     "area_id" INTEGER,
ALTER COLUMN "lat" DROP NOT NULL,
ALTER COLUMN "lat" SET DATA TYPE DECIMAL(9,6),
ALTER COLUMN "lng" DROP NOT NULL,
ALTER COLUMN "lng" SET DATA TYPE DECIMAL(9,6);

-- AlterTable
ALTER TABLE "areas" ADD COLUMN     "centroid" geometry(Point, 4326) NOT NULL;

-- AlterTable
ALTER TABLE "business_locations" ADD COLUMN     "apartment" TEXT,
ADD COLUMN     "details" TEXT,
ALTER COLUMN "lat" SET DATA TYPE DECIMAL(9,6),
ALTER COLUMN "lng" SET DATA TYPE DECIMAL(9,6);

-- AlterTable
ALTER TABLE "clients" DROP COLUMN "first_name",
DROP COLUMN "last_name";

-- AlterTable
ALTER TABLE "conversations" DROP CONSTRAINT "conversations_pkey",
DROP COLUMN "wa_id",
ADD COLUMN     "client_id" INTEGER NOT NULL,
ADD COLUMN     "id" SERIAL NOT NULL,
ADD CONSTRAINT "conversations_pkey" PRIMARY KEY ("id");

-- AlterTable
ALTER TABLE "order_events" ADD COLUMN     "actor_rider_id" INTEGER,
ADD COLUMN     "assignment_id" INTEGER,
ADD COLUMN     "from_status" "order_status",
ADD COLUMN     "to_status" "order_status" NOT NULL;

-- AlterTable
ALTER TABLE "order_forms" DROP COLUMN "wa_id",
ADD COLUMN     "client_id" INTEGER NOT NULL;

-- AlterTable
ALTER TABLE "orders" ADD COLUMN     "dropoff_address_id" INTEGER,
ADD COLUMN     "dropoff_apartment" TEXT,
ADD COLUMN     "dropoff_building" TEXT,
ADD COLUMN     "dropoff_floor" TEXT,
ADD COLUMN     "dropoff_landmark" TEXT,
ADD COLUMN     "pickup_address_id" INTEGER,
ADD COLUMN     "pickup_apartment" TEXT,
ADD COLUMN     "pickup_area_id" INTEGER,
ADD COLUMN     "pickup_building" TEXT,
ADD COLUMN     "pickup_business_location_id" INTEGER,
ADD COLUMN     "pickup_floor" TEXT,
ADD COLUMN     "pickup_landmark" TEXT;

-- AlterTable
ALTER TABLE "wa_messages" ADD COLUMN     "attempts" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "last_error" TEXT,
ADD COLUMN     "order_id" INTEGER;

-- CreateTable
CREATE TABLE "zone_prices" (
    "from_zone" TEXT NOT NULL,
    "to_zone" TEXT NOT NULL,
    "price_usd" DECIMAL(8,2) NOT NULL,

    CONSTRAINT "zone_prices_pkey" PRIMARY KEY ("from_zone","to_zone")
);

-- CreateTable
CREATE TABLE "order_assignments" (
    "id" SERIAL NOT NULL,
    "order_id" INTEGER NOT NULL,
    "rider_id" INTEGER NOT NULL,
    "token_hash" TEXT NOT NULL,
    "assigned_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "assigned_by_id" TEXT,
    "expires_at" TIMESTAMPTZ(6),
    "revoked_at" TIMESTAMPTZ(6),
    "revoked_by_id" TEXT,
    "revoked_reason" TEXT,

    CONSTRAINT "order_assignments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "_OrderAssignmentToOrderEvent" (
    "A" INTEGER NOT NULL,
    "B" INTEGER NOT NULL,

    CONSTRAINT "_OrderAssignmentToOrderEvent_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateIndex
CREATE UNIQUE INDEX "order_assignments_token_hash_key" ON "order_assignments"("token_hash");

-- CreateIndex
CREATE INDEX "order_assignments_order_id_assigned_at_idx" ON "order_assignments"("order_id", "assigned_at");

-- CreateIndex
CREATE INDEX "order_assignments_rider_id_idx" ON "order_assignments"("rider_id");

-- CreateIndex
CREATE INDEX "_OrderAssignmentToOrderEvent_B_index" ON "_OrderAssignmentToOrderEvent"("B");

-- CreateIndex
CREATE INDEX "conversations_client_id_idx" ON "conversations"("client_id");

-- CreateIndex
CREATE INDEX "order_events_actor_rider_id_idx" ON "order_events"("actor_rider_id");

-- CreateIndex
CREATE INDEX "order_forms_wa_id_idx" ON "order_forms"("client_id", "created_at");

-- CreateIndex
CREATE INDEX "wa_messages_order_id_idx" ON "wa_messages"("order_id");

-- CreateIndex
CREATE INDEX "zones_geom_idx" ON "zones" USING GIST ("geom");

-- AddForeignKey
ALTER TABLE "zone_prices" ADD CONSTRAINT "zone_prices_from_zone_fkey" FOREIGN KEY ("from_zone") REFERENCES "zones"("code") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "zone_prices" ADD CONSTRAINT "zone_prices_to_zone_fkey" FOREIGN KEY ("to_zone") REFERENCES "zones"("code") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "addresses" ADD CONSTRAINT "addresses_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "clients"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "addresses" ADD CONSTRAINT "addresses_zone_fkey" FOREIGN KEY ("zone") REFERENCES "zones"("code") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "addresses" ADD CONSTRAINT "addresses_area_id_fkey" FOREIGN KEY ("area_id") REFERENCES "areas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversations" ADD CONSTRAINT "conversations_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "clients"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_pickup_zone_fkey" FOREIGN KEY ("pickup_zone") REFERENCES "zones"("code") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_dropoff_zone_fkey" FOREIGN KEY ("dropoff_zone") REFERENCES "zones"("code") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_pickup_area_id_fkey" FOREIGN KEY ("pickup_area_id") REFERENCES "areas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_dropoff_area_id_fkey" FOREIGN KEY ("dropoff_area_id") REFERENCES "areas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_events" ADD CONSTRAINT "order_events_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_events" ADD CONSTRAINT "order_events_actor_user_id_fkey" FOREIGN KEY ("actor_user_id") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_events" ADD CONSTRAINT "order_events_actor_rider_id_fkey" FOREIGN KEY ("actor_rider_id") REFERENCES "riders"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_forms" ADD CONSTRAINT "order_forms_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "clients"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_assignments" ADD CONSTRAINT "order_assignments_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_assignments" ADD CONSTRAINT "order_assignments_rider_id_fkey" FOREIGN KEY ("rider_id") REFERENCES "riders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_assignments" ADD CONSTRAINT "order_assignments_assigned_by_id_fkey" FOREIGN KEY ("assigned_by_id") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_assignments" ADD CONSTRAINT "order_assignments_revoked_by_id_fkey" FOREIGN KEY ("revoked_by_id") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wa_messages" ADD CONSTRAINT "wa_messages_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_OrderAssignmentToOrderEvent" ADD CONSTRAINT "_OrderAssignmentToOrderEvent_A_fkey" FOREIGN KEY ("A") REFERENCES "order_assignments"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_OrderAssignmentToOrderEvent" ADD CONSTRAINT "_OrderAssignmentToOrderEvent_B_fkey" FOREIGN KEY ("B") REFERENCES "order_events"("id") ON DELETE CASCADE ON UPDATE CASCADE;
