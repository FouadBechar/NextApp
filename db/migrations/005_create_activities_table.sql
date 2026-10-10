-- DISABLED: Duplicate migration. The canonical 'create activities' migration is located at
-- `scripts/migrations/2025-11-02-create-activities-table.sql` and we have an ALTER migration
-- in `db/migrations/006_alter_activities_add_metadata_nullable_userid.sql` to add metadata and adjust user_id nullability.
-- Keep this file for history/fallback but do not apply it in the new migration chain.

