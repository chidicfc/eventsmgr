require "yeasu"
include Yeasu

Yeasu::Radio.configuration do |config|
  config.producer.name = "eventsmgr"
end

session = {}
value1 = {}
value1["session_id"] = "e25ae5e481f8f9786695c73a371b85ab"
value1["return_to"] = "/dashboard"

session["session"] = value1
session["timezone"] = "Europe/London"
session["last_location"] = "http://local.ciabos.dev/dashboard"

value2 = {}
value2["id"] = 21087
value2["username"] = "delaney burke"
value2["encrypted_password"] = "$2a$10$c4zmtR9DEYkB9rxOsLvTwOALyGLtmimByhfgbLTIpXHF77IeHQ6TC"
value2["password_salt"] = nil
value2["reset_password_token"] = nil
value2["remember_token"] = "CzJwdnVx4qNA65p1R5tq"
value2["remember_created_at"] = "2014-10-21T15:06:12+01:00"
value2["created_at"] = "2013-11-14T10:59:31+00:00"
value2["updated_at"] = "014-10-21T15:06:12+01:000"
value2["archive"] = false
value2["legacy_db_id"] = nil
value2["legacy_db_column"] = "L_ID"
value2["legacy_db_table"] = "tblLogins"
value2["email"] = "adam.gorbert@hotmail.co.uk"
value2["team_leader_id"] = nil
value2["confirmation_token"] = nil
value2["confirmed_at"] = "2013-11-14T13:27:56+00:00"
value2["confirmation_sent_at"] = "2013-11-14T10:59:31+00:00"
value2["roles_mask"] = 255

session["current_user"] = value2


Radio::Tunner.broadcast tags: "ciabos,ui,outbound,#{settings.environment[0..3]},sso" do |transmitter|

  transmission = Radio::Transmission.new
  transmission.session = session
  transmission.status = "pass"
  t = transmitter.transmit transmission

end
