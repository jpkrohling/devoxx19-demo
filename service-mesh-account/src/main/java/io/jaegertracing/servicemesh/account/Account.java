package io.jaegertracing.servicemesh.account;

import java.util.UUID;

public class Account {
    private String id;

    public Account() {
        this.id = UUID.randomUUID().toString();
    }

    public Account(String id) {
        this.id = id;
    }

    public String getId() {
        return this.id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public Account id(String id) {
        this.id = id;
        return this;
    }

    @Override
    public String toString() {
        return "{" +
            " id='" + getId() + "'" +
            "}";
    }

}