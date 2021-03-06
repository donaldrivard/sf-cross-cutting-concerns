/**
 * Copyright (c) 2016-2019, Bill Anderson.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *
 *   * Neither the name of Bill Anderson nor the names of its
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *
 * @author Bill Anderson
 * @description Handles Platform Events Disptaching (after insert only).Supports
 * invocation by (1) accc_ITriggerHandler or by (2) Type ( the latter assumes a Trigger Handler)
 *
 * @group Common Layer
 */
public without sharing class accc_ApexPlatformEventDispatcher {

    /////////////////////////////////////////////////////////////////////////
    // Data Members
    /////////////////////////////////////////////////////////////////////////
    // use for testing exception
    @TestVisible
    static Boolean useForTestingException=false;
    /////////////////////////////////////////////////////////////////////////
    // Public Methods
    /////////////////////////////////////////////////////////////////////////

    /**
     * @description The type of event (PE/CDC) we will use to lookup in the Trigger Handler.
     * The code below is commented out if you are not incorporating the trigger handler found
     * here ( https://github.com/bjanderson70/sf-trigger-handling )
     *
     * @param Type handlerType
     * @return Boolean
     */
    public static Boolean run(Type handlerType) {
        Boolean result = false;
        // simple check to ensure the type is not null
        if ( handlerType != null ) {
            try {
                //
                // cause exception testing via injection
                //
                if ( true == accc_ApexPlatformEventDispatcher.useForTestingException
                     && accc_ApexConstants.UNIT_TEST_RUNNING) {
                    throw new accc_ApexApplicationException('accc_ApexPlatformEventDispatcher: accc_ApexApplicationException');
                }
                /***************** FOR TRIGGER HANDLER FRAMEWORK ************************************
                 *
                   [Step 1] - If you decide to load the sf-trigger-handler, then uncomment this portion and the next
                 *
                accc_TriggerMediator triggerMediator = new accc_TriggerMediator(handlerType);
                 */


                // keep -- as this will log to an internal set during testing; otherwise, no-op
                accc_ApexUtilities.logForTesting('accc_ApexPlatformEventDispatcher.handlerType=' + handlerType);
                result = true;
                /**************** FOR TRIGGER HANDLER FRAMEWORK ************************************
                 *
                   [Step 2] -  Requires the sf-trigger-handler framework
                // invoke trigger handlers related to the AfterInsert ( for events, only after insert)
                result = triggerMediator.execute(accc_TriggerHelperClass.TriggerState.AfterInsert);
                 */

            } catch (Exception excp) {
                accc_ApexUtilities.log(excp);
            }
            // returns true if successful; false if an exception occurs and not handled
            // keep -- as this will log to an internal set during testing; otherwise, no-op
            accc_ApexUtilities.logForTesting('accc_ApexPlatformEventDispatcher result=' + result);
        } else {
            Exception excp = new accc_PlatformEventException('accc_ApexPlatformEventDispatcher invoked with a null type');
            accc_ApexUtilities.log(excp);
        }
        return result;
    }   // end of run
    /**
     * @description run the platform event handler
     *
     * @param accc_ITriggerHandler apex platform event handler
     */
    public static Boolean run(accc_ITriggerHandler handler) {
        Boolean result = true;
        // keep -- as this will log to an internal set during testing; otherwise, no-op
        accc_ApexUtilities.logForTesting('accc_ApexPlatformEventDispatcher handler=' + handler);

        // valid handler (Trigger.New can be null if calling from non-trigger [testing])
        // only handle after insert for dispatching platform events
        if (handler != null
            && Trigger.New != null
            && Trigger.IsAfter
            && Trigger.IsInsert) {
            String name = accc_ApexUtilities.getClassName(handler);
            // keep -- as this will log to an internal set during testing; otherwise, no-op
            accc_ApexUtilities.logForTesting('accc_ApexPlatformEventDispatcher.name=' + name);

            // protect against recursion
            if ( !accc_TriggerHelperClass.hasBeenCalled(name, accc_TriggerHelperClass.TriggerState.AfterInsert) ) {
                // toggle our state
                accc_TriggerHelperClass.toggleRunState(name, accc_TriggerHelperClass.TriggerState.AfterInsert);
                // call handler
                handler.onAfterInsertChild(Trigger.New);
            }
        } else {
            result = false;
        }
        return result;
    } // end of run
} // end of accc_ApexPlatformEventDispatcher
