# Performance Monitor for Windows & NVIDIA GPUs
# Version 1.2 by Mr_Superjaffa#5430
#
# Thanks to Alexey Kamenev for his GPUPerfCounters

#### Requirements
1. NVIDIA GPU. Both TCC and WDDM Modes are supported.
2. Lastest [drivers](http://www.nvidia.com/Download/index.aspx).

# Install:
1. Run the following command line from the GpuPerfCounters folder, this may require administrator privileges:
```
GpuPerfCounters.exe -install
```
2. Now that the GPU performance counters service is installed, we start it with:
```
sc start GpuPerfCounters
```
3. Open up the `PerfMonitorConfig.xml` file and configure to your needs.
4. Run the `PerfMonitorStart.bat`, it will momentarily begin collecting stats.

Additionally to the PS script, you can vew the GPU performance counters through PerfMon, just add counters from the `GPU` category.

#### Uninstall
1. Stop the `GpuPerfCounters` service:
```
sc stop GpuPerfCounters
```
2. Remove the service from the registry:
```
GpuPerfCounters.exe -uninstall
```

#### Limitations

1. Currently the Perf Monitor will not work with processes with child processes. I hope to rectify this in a later version.