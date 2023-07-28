package com.example.train_api.exeption;

import com.fasterxml.jackson.annotation.JsonInclude;

public class Response {

    private String error;
    @JsonInclude(JsonInclude.Include.NON_NULL)
    private String debugMessage;

    public Response() {
    }

    public Response(String error) {
        this.error = error;
    }

    public Response(String error, String debugMessage) {
        this.error = error;
        this.debugMessage = debugMessage ;
    }

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }

    public String getDebugMessage() {
        return debugMessage;
    }

    public void setDebugMessage(String debugMessage) {
        this.debugMessage = debugMessage;
    }
}
