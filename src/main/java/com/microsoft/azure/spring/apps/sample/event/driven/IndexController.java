package com.microsoft.azure.spring.apps.sample.event.driven;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class IndexController {

    @GetMapping
    public String index() {
        return """
                 <div class="intro" style="font-family: Arial, sans-serif; line-height: 1.6; background-color: #f7f7f7; padding: 20px; text-align: center;">
                    <h1>Welcome to the event-driven application!</h1>
                   <p>
                   The sample project is an event-driven application that subscribes to a Service Bus queue named <strong>lower-case</strong>, and then handles the message and sends another message to another queue named <b>upper-case</b>. To make the app simple, message processing just converts the message to uppercase.
                   </p>
                 </div>
                  
                 <div class="image-container" style="font-family: Arial, sans-serif; line-height: 1.6; display: flex; flex-direction: column; justify-content: center; align-items: center; margin: 20px 0;">
                   <p style="text-align: center;">
                    The following diagram depicts this process: 
                   </p>
                   <img
                     src="https://learn.microsoft.com/azure/spring-apps/media/quickstart-deploy-event-driven-app/diagram.png" alt="The event-driven process"
                     alt="The event-driven application diagram"
                     style="max-width: 50%; height: auto; border-radius: 10px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);"
                   >
                 </div>
                 
                 <div class="content" style="font-family: Arial, sans-serif; line-height: 1.6; padding: 20px;">
                    <h3>Use the following steps to confirm that the event-driven app works correctly.</h3>
                    <p>
                    You can validate the app by sending a message to the <strong>lower-case</strong> queue, then confirm that there's a message in the <strong>upper-case</strong> queue.
                    </p>
                    <ol>
                        <li>
                        Send a message to the <strong>lower-case</strong> queue with <i><strong>Service Bus Explorer</i></strong>. For more information, see the <a href="https://learn.microsoft.com/azure/service-bus-messaging/explorer#send-a-message-to-a-queue-or-topic">How to send a message to a queue or topic</a>.
                        </li>
                        <li>
                        Confirm that there's a new message sent to the <strong>upper-case</strong> queue. For more information, see <a href="https://learn.microsoft.com/azure/service-bus-messaging/explorer#peek-a-message">How to peek a message section</a>.
                        </li>
                       
                    </ol>
                    <p>
                    Please refer to <a href="https://learn.microsoft.com/azure/spring-apps/quickstart-deploy-event-driven-app#5-validate-the-app">the quickstart doc</a> for more details.   
                    </p>
                 </div>
                
                """;
    }

}
