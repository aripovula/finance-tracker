# Known plaintext credentials for the 3 preset demo accounts. Used both to
# seed them (db/seeds.rb) and to power the one-click "quick demo login" on
# the login page (app/views/sessions/new.html.erb) - the password really is
# visible in the page source. That's deliberate: this is a public portfolio
# demo with no real user data, and the point is letting a visitor log in
# without registering or guessing credentials. Passwords are different
# lengths on purpose, so the prefill is visibly working as you switch users.
module DemoUserPresets
  ALL = [
    { name: "Alex", password: "alex123" },
    { name: "Ann", password: "annpassword12" },
    { name: "John", password: "johndemopassword2024" }
  ].freeze
end
