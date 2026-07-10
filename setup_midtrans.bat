@echo off
echo ===============================================
echo   ParQr - Midtrans Setup Helper
echo ===============================================
echo.

echo Langkah-langkah setup Midtrans:
echo.
echo 1. Daftar/Login ke Midtrans Sandbox
echo    URL: https://dashboard.sandbox.midtrans.com
echo.
echo 2. Dapatkan Server Key
echo    Dashboard ^> Settings ^> Access Keys ^> Server Key
echo    Format: SB-Mid-server-xxxxxxxxxxxxx
echo.
echo 3. Set di Supabase
echo    URL: https://supabase.com/dashboard/project/rtchxgkayaquwzuicuzy/settings/functions
echo    Klik "Manage secrets" ^> Add new secret:
echo      Key: MIDTRANS_SERVER_KEY
echo      Value: (paste Server Key Anda)
echo.
echo 4. Deploy Edge Functions (via Supabase CLI)
echo    supabase functions deploy midtrans_charge
echo    supabase functions deploy midtrans_webhook
echo.
echo 5. Test di Aplikasi
echo    flutter run --dart-define-from-file=.env
echo.
echo ===============================================

echo.
echo Buka dokumentasi lengkap? (Y/N)
set /p open_doc=^> 

if /i "%open_doc%"=="Y" (
    start MIDTRANS_SETUP.md
)

echo.
echo Buka Midtrans Dashboard? (Y/N)
set /p open_midtrans=^> 

if /i "%open_midtrans%"=="Y" (
    start https://dashboard.sandbox.midtrans.com
)

echo.
echo Buka Supabase Edge Functions Settings? (Y/N)
set /p open_supabase=^> 

if /i "%open_supabase%"=="Y" (
    start https://supabase.com/dashboard/project/rtchxgkayaquwzuicuzy/settings/functions
)

echo.
echo Done! Ikuti langkah-langkah di atas untuk setup Midtrans.
pause
