package io.jaegertracing.servicemesh.order;

import java.util.UUID;

import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.eclipse.microprofile.rest.client.inject.RestClient;

import io.opentracing.Scope;
import io.opentracing.Tracer;

@Path("/")
public class RootEndpoint {

    @Inject
    @RestClient
    AccountsService accountsService;

    @Inject
    @RestClient
    InventoryService inventoryService;

    @Inject
    Tracer tracer;

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String submit() {
        try (Scope scope = tracer.buildSpan("submitOrder").startActive(true)) {
            scope.span().setTag("priority", "high");
            Account account = accountsService.getAccount();
            Order order = new Order(UUID.randomUUID().toString(), account);
            inventoryService.processOrder(order);
            return String.format("Order submitted: %s", order);
        }
    }
}