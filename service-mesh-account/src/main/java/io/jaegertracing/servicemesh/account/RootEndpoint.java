package io.jaegertracing.servicemesh.account;

import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import io.opentracing.Scope;
import io.opentracing.Tracer;

@Path("/")
public class RootEndpoint {

    @Inject
    Tracer tracer;

    @Inject
    AccountRepository accountRepository;

    @GET
    @Produces({MediaType.APPLICATION_JSON, MediaType.TEXT_PLAIN})
    public Account getAccount() {
        try (Scope scope = tracer.buildSpan("getAccount").startActive(true)) {
            Account account = accountRepository.getAccountFromCache();
            if (null == account) {
                account = accountRepository.getAccountFromStorage();
            }
            return account;
        }
    }
}