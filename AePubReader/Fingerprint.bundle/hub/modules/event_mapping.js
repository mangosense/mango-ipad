//
//  Copyright 2013 Fingerprint Digital, Inc. All rights reserved.
//

var gEventScope1 = "XYZ";
var gEventScope2 = "ABCDE";

function FPSetEventScope1(s)
{
    gEventScope1 = s;
}

function FPSetEventScope2(s)
{
    gEventScope2 = s;
}

function FPGetScreenToken(screen)
{
    var screenName = gEventScreenNameMap[screen];
    if (!screenName) {
        screenName = screen;
    }
    var eventName = "FPP/" + gEventScope1 + "/" + gEventScope2 + "/" + screenName;
    return eventName;
}

function FPGetEventToken(screen, button)
{
    var eventName = FPGetScreenToken(screen) + ":" + button;
    return eventName;
}

var gEventScreenNameMap = {
    alert_guestLogout: "Guest Logout Alert",
    alert_screen: "Alert",
    are_you_parent: "Are You Parent?",
    change_account_settings: "Change Account Settings",
    change_player: "Change Player",
    delayed_offline: "Delayed Offline",
    edit_message_preferences: "Edit Message Preferences",
    edit_real_name: "Edit Real Name",
    enter_custom_server: "Enter Custom Server",
    find_by_email_phone: "Find by Email or Phone",
    find_by_username: "Find by Username",
    game_pause: "Pause",
    guest_name: "Guest Name",
    hub: "Hub",
    hub_about: "About",
    hub_account_settings: "Account Settings",
    hub_change_avatar: "Change Avatar",
    hub_child_profile: "Child Profile",
    hub_coins: "Coin-o-copia",
    hub_coins_help: "Coin-o-copia Help",
    hub_create_message: "Create Message",
    hub_edit_players: "Edit Players",
    hub_find_friends: "Find Friends",
    hub_friend_profile: "Friend Profile",
    hub_friends: "Friends",
    hub_friends_mayknow: "Friend Suggestions",
    hub_games_main: "Games Main",
    hub_help: "Help",
    hub_home: "Home",
    hub_messages: "Messages",
    hub_parent_home: "Parent Home",
    hub_privacy_tos: "Privacy or TOS",
    hub_remove_players: "Remove Players",
    hub_sell: "Upsell",
    hub_settings: "Settings",
    offline: "Offline",
    parent_gate: "Parent Gate",
    pick_avatar: "Pick Avatar",
    play_as_a_family: "Reasons to Register",
    player_real_names: "Real Names",
    registration_change_login: "Email Already Registered",
    registration_congratulations: "Registration Complete",
    registration_create: "Create Account",
    registration_forgot_pwd: "Forgot Password",
    registration_login: "Login",
    registration_pp: "Privacy Policy",
    registration_tos: "TOS",
    select_play_options: "Select Registration",
    updater: "Updater",
    usersetup_children: "Setup Children",
    versions: "Show Versions"
};
