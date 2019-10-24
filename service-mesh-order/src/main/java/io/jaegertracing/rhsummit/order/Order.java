package io.jaegertracing.rhsummit.order;

public class Order {
    private String orderId;
    private Account account;

    public Order() {
    }

    public Order(String orderId, Account account) {
        this.orderId = orderId;
        this.account = account;
    }

    public String getOrderId() {
        return this.orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public Account getAccount() {
        return this.account;
    }

    public void setAccount(Account account) {
        this.account = account;
    }

    public Order orderId(String orderId) {
        this.orderId = orderId;
        return this;
    }

    public Order account(Account account) {
        this.account = account;
        return this;
    }

    @Override
    public String toString() {
        return "{" +
            " orderId='" + getOrderId() + "'" +
            ", account='" + getAccount() + "'" +
            "}";
    }

}