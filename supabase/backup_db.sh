#!/bin/bash

# ==============================================================================
# Database Backup Script for ParQr
# ==============================================================================

# Petunjuk Penggunaan:
# 1. Pastikan PostgreSQL client (`pg_dump`) terinstall di sistem Anda.
# 2. Isi variabel `DB_HOST`, `DB_PASSWORD`, `DB_USER`, dan `DB_NAME` sesuai
#    dengan project Supabase Anda (bisa dilihat di dashboard > Project Settings > Database).
# 3. Jalankan script ini: `sh backup_db.sh` atau `./backup_db.sh`.

export DB_HOST="db.yourproject.supabase.co"
export DB_PORT="5432"
export DB_USER="postgres"
export DB_NAME="postgres"
export PGPASSWORD="your_database_password_here"

# Format nama file backup (contoh: parqr_backup_20260618_153022.dump)
BACKUP_FILE="parqr_backup_$(date +%Y%m%d_%H%M%S).dump"

echo "Mulai proses backup database ParQr dari host: $DB_HOST..."

# Menjalankan pg_dump dengan format custom (-F c) yang direkomendasikan Supabase
pg_dump \
  -h $DB_HOST \
  -p $DB_PORT \
  -U $DB_USER \
  -d $DB_NAME \
  -F c \
  -b -v \
  -f $BACKUP_FILE

if [ $? -eq 0 ]; then
  echo "✅ Backup berhasil! File disimpan sebagai: $BACKUP_FILE"
else
  echo "❌ Backup gagal! Periksa kredensial atau koneksi jaringan Anda."
fi
