FROM osrf/ros:humble-desktop-full

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV ROS_DISTRO=humble
ENV TURTLEBOT3_MODEL=waffle

USER root

# Dev tools + locale
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        gnupg \
        lsb-release \
        software-properties-common \
        locales \
        sudo \
        wget \
        nano \
        gedit \
        terminator \
        iproute2 \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && add-apt-repository universe -y \
    && rm -rf /var/lib/apt/lists/*

# Add OSRF Gazebo repository
RUN curl -sSL https://packages.osrfoundation.org/gazebo.gpg \
        -o /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] \
       http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" \
       > /etc/apt/sources.list.d/gazebo-stable.list

# Install Gazebo Fortress, ROS-Gazebo bridge, Nav2, TurtleBot3, ros2-control, teleop
RUN apt-get update && apt-get install -y --no-install-recommends \
        ignition-fortress \
        ros-humble-ros-gz \
        ros-humble-ros-gz-sim \
        ros-humble-ros-gz-bridge \
        ros-humble-ros-gz-image \
        ros-humble-navigation2 \
        ros-humble-nav2-bringup \
        ros-humble-turtlebot3 \
        ros-humble-turtlebot3-gazebo \
        ros-humble-teleop-twist-keyboard \
        ros-humble-ros2-control \
        ros-humble-ros2-controllers \
        ros-humble-gz-ros2-control \
        python3-colcon-common-extensions \
        python3-rosdep \
        python3-shapely \
    && rm -rf /var/lib/apt/lists/*

# Initialize rosdep
RUN rosdep init 2>/dev/null || true \
    && rosdep update

# Non-root user with sudo
RUN adduser --disabled-password --gecos '' user \
    && adduser user sudo \
    && passwd -d user

RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/user/.bashrc \
    && echo "export TURTLEBOT3_MODEL=waffle" >> /home/user/.bashrc \
    && chown user:user /home/user/.bashrc

USER user
WORKDIR /ros2_ws
COPY --chown=user:user src/ src/

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
