String broker           = 'soldier.cloudmqtt.com';
  int port                = 13391 ;
  String username         = 'qzmlgsle';
  String passwd           = '_bVD3pryg2wc';
  String clientIdentifier = 'android';

  mqtt.MqttClient client;
  mqtt.MqttConnectionState connectionState;
  StreamSubscription subscription;

 void _subscribeToTopic(String topic) {
    if (connectionState == mqtt.MqttConnectionState.connected) {
        print('[MQTT client] Subscribing to ${topic.trim()}');
        client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
    }
  }

  void _subscribeToTopicTwo(String topic) {
    if (connectionState == mqtt.MqttConnectionState.connected) {
        print('[MQTT client] Subscribing to ${topic.trim()}');
        client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
    }
  }

   Future _connect() async {

    client = mqtt.MqttClient(broker, '');
    client.port = port;

   
    client.logging(on: true);

    /// If you intend to use a keep alive value in your connect message that is not the default(60s)
    /// you must set it here
    client.keepAlivePeriod = 30;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = _onDisconnected;

 
    final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .authenticateAs('test', 'test')
        .startClean() // Non persistent session for testing
        .keepAliveFor(30)
        .withWillQos(mqtt.MqttQos.atMostOnce);
    print('[MQTT client] MQTT client connecting....');
    client.connectionMessage = connMess;


    try {
      await client.connect(username, passwd);
    } catch (e) {
      print(e);
      _disconnect();
    }

    /// Check if we are connected
    if (client.connectionStatus.state == mqtt.MqttConnectionState.connected) {
      print('[MQTT client] connected');
      setState(() {
        connectionState = client.connectionStatus.state;
      });
    } else {
      print('[MQTT client] ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client.connectionStatus.state}');
      _disconnect();
    }

    subscription = client.updates.listen(_onMessage);
    subscription = client.updates.listen(_onMessageTwo);

    _subscribeToTopic("room/lamp");
     _subscribeToTopicTwo("room/lamp2");

  }

  void _disconnect() {
    print('[MQTT client] _disconnect()');
    client.disconnect();
    _onDisconnected();

    
  }

  void _onDisconnected() {
    print('[MQTT client] _onDisconnected');
    setState(() {
      //topics.clear();
      connectionState = client.connectionStatus.state;
      client = null;
      subscription.cancel();
      subscription = null;
    });
    print('[MQTT client] MQTT client disconnected');
  }


 



 void _onMessage(List<mqtt.MqttReceivedMessage> event) {
    print(event.length);
    final mqtt.MqttPublishMessage recMess =
    event[0].payload as mqtt.MqttPublishMessage;
    final String message =
    mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

  
    print('[MQTT client] MQTT message: topic is <${event[0].topic}>, '
        'payload is <-- $message -->');
    print(client.connectionStatus.state);
    print("[MQTT client] message with topic: ${event[0].topic}");
    print("[MQTT client] message with message: $message");
    setState(() {
     // _temp = double.parse(message);
     if(message == "on") {
      
        _switchValue =true;
       
         print('switchValue is equals to: $_switchValue');
     }
     else if(message == "off") {
      
        _switchValue = false;
       
          print('switchValue is equals to: $_switchValue');
     }
    });
  }
