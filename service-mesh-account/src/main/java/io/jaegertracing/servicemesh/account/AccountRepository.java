package io.jaegertracing.servicemesh.account;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;

import org.eclipse.microprofile.opentracing.Traced;

import io.opentracing.Tracer;
import io.opentracing.tag.Tags;

@Traced
@ApplicationScoped
public class AccountRepository {
    @Inject
    Tracer tracer;

    public Account getAccountFromCache() {
        Tags.ERROR.set(tracer.activeSpan(), true);
        return null;
    }

    public Account getAccountFromStorage() {
        return new Account();
    }
}