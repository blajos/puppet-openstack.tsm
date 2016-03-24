# Fact: default_gateway
#
# Purpose: get default gateway
#
# Resolution:
#   Parses default gw from "ip r" commands output
#
# Caveats:
#   none
#
# Notes:
#   None
Facter.add('default_gateway') do
  gw_cmd = 'ip r|grep ^default'
  gw_result = Facter::Util::Resolution.exec(gw_cmd)
  setcode do
    gw_result.to_s.lines.first.strip.split(/ /)[2]
  end
end


