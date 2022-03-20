#!/system/xbin/bash
ST_CALIBRATION_PERSIST_DIR="${1}"
ST_FACTORY_DATA_PATH="${2}"

echo "Checking gyroscope calibration..."
cmp --silent "${ST_FACTORY_DATA_PATH}/gyro.txt" "${ST_CALIBRATION_PERSIST_DIR}/gyro.txt" || \
    (echo "Changes found! Copying now..." && \
    cp -f ${ST_CALIBRATION_PERSIST_DIR}/gyro.txt ${ST_FACTORY_DATA_PATH}/gyro.txt &&
    chmod 666 ${ST_FACTORY_DATA_PATH}/*)

echo "Calibration table up to date."
