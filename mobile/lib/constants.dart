import 'package:flutter/material.dart';

const String appName = 'trgtz';
// const String endpoint = 'https://api.trgtz.com';
const String endpoint = 'http://10.0.2.2:3000';
const String loremIpsum =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.';

const Color mainColor = Color(0xFF00242C);
const Color secondaryColor = Color(0xFFCDF6FF);
const Color accentColor = Color(0xFFED5076);

// Broadcast message types
const String broadcastTypeSubscribeChannel = 'SUBSCRIBE_CHANNEL';
const String broadcastTypeUnsubscribeChannel = 'UNSUBSCRIBE_CHANNEL';

const String broadcastChannelTypeUser = 'USER';
const String broadcastTypeUserUpdate = 'USER_UPDATE';

const String broadcastChannelTypeFriends = 'FRIENDS';
const String broadcastTypeFriendRequest = 'FRIEND_REQUEST';
const String broadcastTypeFriendAccepted = 'FRIEND_REQUEST_ACCEPTED';
const String broadcastTypeFriendDeleted = 'FRIEND_DELETED';

const String broadcastTypeGoalUpdate = 'GOAL_UPDATE';

const String broadcastChannelTypeAlerts = 'ALERTS';
const String broadcastTypeNewAlert = 'NEW_ALERT';
