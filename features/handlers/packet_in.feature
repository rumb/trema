Feature: packet_in handler
  Background:
    Given a file named "packet_in_controller.rb" with:
      """ruby
      class PacketInController < Trema::Controller
        def packet_in(dpid, message)
          logger.info "new packet_in (dpid = #{dpid.to_hex})"
        end
      end
      """
    And a file named "trema.conf" with:
      """ruby
      vswitch { datapath_id 0xabc }
      vhost('host1') { ip '192.168.0.1' }
      vhost('host2') { ip '192.168.0.2' }
      link '0xabc', 'host1'
      link '0xabc', 'host2'
      """

  @sudo
  Scenario: invoke packet_in handler
    Given I successfully run `trema run packet_in_controller.rb -c trema.conf -d`
    And I successfully run `sleep 3`
    When I successfully run `trema send_packets --source host1 --dest host2`
    Then the file "PacketInController.log" should contain "new packet_in (dpid = 0xabc)"

  @sudo
  Scenario: invoke packet_in handler (OpenFlow 1.3)
    Given I successfully run `trema run packet_in_controller.rb -c trema.conf --openflow13 -d`
    And I successfully run `sleep 3`
    When I successfully run `trema send_packets --source host1 --dest host2`
    Then the file "PacketInController.log" should contain "new packet_in (dpid = 0xabc)"
