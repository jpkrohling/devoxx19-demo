package io.jaegertracing.rhsummit.order;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;

@Path("/")
@RegisterRestClient
public interface AccountsService {
    @GET
    @Path("/")
    @Produces(MediaType.APPLICATION_JSON)
    Account getAccount();
}