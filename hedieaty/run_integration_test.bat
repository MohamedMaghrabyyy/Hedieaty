
Start-Process -NoNewWindow -FilePath adb -ArgumentList shell screenrecord --size 1440x3120 /sdcard/test_video.mp4-PassThru

flutter drive --device-id="emulator-5554" --driver=./test_driver/integration_test_driver.dart --target=./test/integration_tests/full_test.dart

adb pull /sdcard/test_video.mp4 test_video.mp4