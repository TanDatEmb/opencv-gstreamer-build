#!/bin/bash
set -e  # Exit on error
OPENCV_VERSION="4.12.0"
OPENCV_DIR="$HOME/Dev"
NUM_CORES=$(nproc)

echo "==> Updating system and installing dependencies..."
sudo apt update && sudo apt install -y \
  build-essential cmake git pkg-config \
  libgtk-3-dev libcanberra-gtk3-dev \
  libavcodec-dev libavformat-dev libswscale-dev \
  libv4l-dev libxvidcore-dev libx264-dev \
  libjpeg-dev libpng-dev libtiff-dev \
  gfortran openexr libatlas-base-dev \
  python3-dev python3-numpy python3-pip \
  libtbb2 libtbb-dev libdc1394-22-dev \
  libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
  libgstreamer-plugins-good1.0-dev gstreamer1.0-gl \
  gstreamer1.0-tools gstreamer1.0-libav \
  libeigen3-dev

echo "==> Downloading OpenCV and opencv_contrib..."
mkdir -p "$OPENCV_DIR"
cd "$OPENCV_DIR"

if [ ! -d "opencv" ]; then
  git clone https://github.com/opencv/opencv.git
fi

if [ ! -d "opencv_contrib" ]; then
  git clone https://github.com/opencv/opencv_contrib.git
fi

cd opencv
git checkout $OPENCV_VERSION
cd ../opencv_contrib
git checkout $OPENCV_VERSION

echo "==> Creating build directory and configuring with CMake..."
cd "$OPENCV_DIR/opencv"
rm -rf build
mkdir build && cd build

cmake -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D OPENCV_EXTRA_MODULES_PATH="$OPENCV_DIR/opencv_contrib/modules" \
      -D WITH_GSTREAMER=ON \
      -D WITH_FFMPEG=ON \
      -D WITH_GTK=ON \
      -D BUILD_opencv_python3=ON \
      -D BUILD_opencv_python2=OFF \
      -D BUILD_EXAMPLES=OFF ..

echo "==> Starting compilation..."
make -j$NUM_CORES

echo "==> Installing OpenCV..."
sudo make install
sudo ldconfig

echo "✅ OpenCV $OPENCV_VERSION installation with GStreamer + GTK completed"
echo "==> Verifying installation..."
python3 -c "import cv2; print('OpenCV version:', cv2.__version__)"
if [ $? -eq 0 ]; then
  echo "OpenCV has been successfully installed!"
else
  echo "An error occurred during OpenCV verification."
fi
echo "==> Cleaning up..."
cd "$OPENCV_DIR/opencv"
rm -rf build
echo "✅ Cleanup completed."
echo "==> Installing required pip packages..."
pip3 install --upgrade pip
pip3 install numpy matplotlib scikit-image scikit-learn opencv-python-headless
echo "✅ Pip packages installation completed."
echo "==> Everything is ready! You can now use OpenCV with GStreamer and GTK."
echo "==> Usage instructions:"
echo "1. Open a terminal and run: python3"
echo "2. Enter the following commands to verify OpenCV:"
echo "   import cv2"
echo "   print(cv2.__version__)"
echo "3. To use GStreamer, you can try the following commands:"
echo "   cap = cv2.VideoCapture('videofile.mp4', cv2.CAP_GSTREAMER)"
echo "   if not cap.isOpened():"
echo "       print('Cannot open video')"
echo "   else:"
echo "       while True:"
echo "           ret, frame = cap.read()"
echo "           if not ret:"
echo "               break"
echo "           cv2.imshow('Video', frame)"
echo "           if cv2.waitKey(1) & 0xFF == ord('q'): break"
echo "   cap.release()"
echo "   cv2.destroyAllWindows()"
echo "==> Notes:"
echo "   - Ensure you have installed GStreamer and the required plugins."
echo "   - If you encounter errors, review the installation steps or search online for solutions."
echo "==> Thank you for using this script! Good luck with OpenCV!"
echo "==> If you need support, visit the OpenCV GitHub page or the Stack Overflow community."
echo "==> To update OpenCV in the future, simply rerun this script."