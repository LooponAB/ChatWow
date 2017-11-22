# ChatWow

## Chat UI library for iOS.

Chat UI framework for iOS. Provides all the basic UI elements necessary to implement a chat interface.

## Using ChatWowViewController

A few things are important to keep in mind when using ChatWowViewController:

There are two types of messages: "messages" and "pending messages".

**Messages** are normal chat messages. They are indexed from newer to older (the most recent message is at index 0). **Messages** can be inserted at any point in the chat log. For example: If you got a delayed message and after sorting it turns out it is the third most recent message, you insert it in the chat log by invoking:

`insert(newMessages: 1, at: 2)`

**Pending Messages** are messages that the user has composed locally and sent to the server, but the delivery has not yet been confirmed. They are drawn with a reduced opacity value (conventional way of marking a message as pending). They are always placed under all **messages**, regardless of their timestamp. They are also indexed from newer to older (most recent message at index 0), but can only be inserted at index 0. Every time a user composes a message and hits send (or presses return on the keyboard), the following delegate method is called:

`chatController:didInsertMessage:`

You should then send the message to your server, and immediately call `insert(pendingMessages: 1)`. The message will be inserted in the bottom part of the chat log. When your server confirms the message was delivered, you should update your data source, and then call:

`commitPendingMessage(with: oldIndex, to: newIndex)`

Where `oldIndex` is the index of the pending message (where it was in the **pending messages** stack), and `newIndex` is the index of the message after being added to the **messages** stack. `ChatWowViewController` will perform an animation giving the user the impression that the **pending message** was moved to the location of the **message**, when in reality the old view was destroyed and a new cell was created instead. This is important because it means you can render pending and normal messages with different views if you so prefer.

### Read timestamp

The only "smart" feature (currently) provided by ChatWow is the read timestamp feature. Based only on the return value of the delegate method `chatController:readDateForMessageWithIndex:`, `ChatWowViewController` will place
and move a label with such information automatically. You are only required to call `setNeedsUpdateReadInfo` when you wish the read timestamp info to be updated.

### Removing messages

`ChatWowViewController` supports removing individual messages from the chat log. Remove the message first from your data source, then call `removeMessageAtIndex:` or `removePendingMessageAtIndex`.

In order to completely clean the chat log, you will need to first empty your data source, then simply call `tableView.reloadData()`.

## Advanced features

### Custom views

If you need to render messages with a custom chat bubble, then you will have to:

- Register the custom views as Nibs on the tableView with a custom reuse identifier.
- Use a custom subclass of `ChatMessage` that returns your reuse identifier as the value of `viewIdentifier:String`
- Properly estimate the height of your custom view as the return value of the data source method
`chatController:estimatedHeightForMessageWithIndex:`

It is recommended to have two Nibs for each custom view, one for each "side" of the conversation, and register them with different reuse identifiers. Then you can pick which "side" Nib to use depending on the side of the associated chat message by returning a different reuse identifier on each case. See the implementation of `ChatImageMessage` as an example.

All built-in chat message views  also use this exact same registration behavior, so if your custom views are not working, have a look at the built-in views and subclasses of `ChatMessage` for a clue on how to do it.

### Failed messages

If you decide a pending message has failed delivery, you can inform the user so by setting the `hasError` field of the respective chat message to true, then calling `updatePendingMessageAtIndex:` to ask the controller to update that chat message in the chat log.

## License

```
BSD 3-clause License

Copyright 2017 Loopon AB

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
may be used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```