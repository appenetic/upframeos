class SystemInfoService
  # Initialize any required variables or services
  def initialize
    @thermal_zone_path = '/sys/devices/virtual/thermal/thermal_zone0/temp'
    @network_interface = 'wlan0'
  end

  # Public method to fetch all system information
  def fetch_system_info
    {
      cpu_temperature: fetch_cpu_temperature,
      cpu_clock: fetch_cpu_clock_speed,
      uptime: fetch_system_uptime,
      v4_ip_address: fetch_ipv4_address
    }
  end

  private

  # Fetches the CPU temperature
  def fetch_cpu_temperature
    cpu_temp_output = `cat #{@thermal_zone_path}`
    cpu_temp_output.to_i / 1000.0
  end

  # Fetches the CPU clock speed
  def fetch_cpu_clock_speed
    cpu_clock_output = `lscpu -e=CPU,MHZ | awk 'NR==3 {print $2}'`
    cpu_clock_output.strip
  end

  # Fetches the system uptime
  def fetch_system_uptime
    uptime_output = `uptime`
    uptime_output.split(',')[0].split('up ')[1].strip
  end

  # Fetches the IPv4 address for a specific interface
  def fetch_ipv4_address
    ip_output = `ip addr show #{@network_interface} | grep 'inet ' | awk '{print $2}' | cut -d/ -f1`
    ip_output.strip
  end
end
