# Docker Environment Setup

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running

## Build the image

From the repo root:

```bash
docker build -t cav_p01 .
```

This will take a while on the first build (~5–10 GB image).

## Run the container

### Without GUI (headless / terminal only)

```bash
docker run -it --rm \
  -v "$(pwd)/src:/ros2_ws/src" \
  cav_p01
```

### With GUI (Linux — X11)

```bash
xhost +local:docker

docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$(pwd)/src:/ros2_ws/src" \
  cav_p01
```

### With GUI (Windows — WSL2 + WSLg)

WSLg provides an X server automatically. Run the command from inside your WSL2 terminal:

```bash
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$(pwd)/src:/ros2_ws/src" \
  cav_p01
```

If `$DISPLAY` is not set, run `echo $DISPLAY` in WSL2 — it should be `:0`. If it's empty, ensure WSLg is enabled (requires Windows 11 / WSL2 kernel 5.10.16+).

### With GUI (Windows — VcXsrv)

1. Install [VcXsrv](https://sourceforge.net/projects/vcxsrv/) and launch XLaunch with **"Disable access control"** checked.
2. Find your host IP: `ipconfig` → look for the WSL or Ethernet adapter address.
3. Run from PowerShell or WSL2:

```bash
docker run -it --rm \
  -e DISPLAY=<YOUR_HOST_IP>:0.0 \
  -v "$(pwd)/src:/ros2_ws/src" \
  cav_p01
```

## Workspace

The `src/` directory is mounted into `/ros2_ws/src` inside the container. Changes on the host are reflected live — no rebuild needed when editing source code.

To build your packages:

```bash
cd /ros2_ws
rosdep install --from-paths src --ignore-src -r -y
colcon build
source install/setup.bash
```

## Quick tests

**Gazebo Fortress:**
```bash
ign gazebo
```

**TurtleBot3 simulation:**
```bash
ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py
```

**Nav2 with TurtleBot3:**
```bash
# Terminal 1 — simulation
ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py

# Terminal 2 — navigation
ros2 launch turtlebot3_navigation2 navigation2.launch.py use_sim_time:=True
```

**Teleop keyboard:**
```bash
ros2 run teleop_twist_keyboard teleop_twist_keyboard
```

## Multiple terminals in the same container

Use `terminator` (installed in the image) for a split-pane terminal, or attach a new shell to a running container:

```bash
docker exec -it <container_name> bash
```

To find the container name: `docker ps`
