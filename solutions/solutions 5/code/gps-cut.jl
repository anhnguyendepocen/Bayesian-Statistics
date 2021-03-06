module GPS

using PyPlot, Distributions
draw_now() = (pause(0.001); get_current_fig_manager()[:window][:raise_]())

# Latitude/longitude measurements from some points in Eno River State Park, NC.
# (Obtained using Google maps)
data = [36.077916 -79.009266
        36.078032 -79.009180
        36.078129 -79.009094
        36.078048 -79.008891
        36.077942 -79.008962
        36.089612 -79.035760  # outlier
        36.077789 -79.008917
        36.077563 -79.009281]

# latitude only:
x = data[:,1]
println("mean(x) = ",mean(x))
println("median(x) = ",median(x))

theta_0 = 36.07
sigma_0 = 0.02
sigma = 0.0002

# prior
P = Cauchy(theta_0,sigma_0)

log_likelihood(x,theta) = sum(logpdf(Cauchy(theta,sigma),x))
likelihood(x,theta) = exp(log_likelihood(x,theta))

# importance sampling distribution
Q = Cauchy(median(x),1e-4)  # (to choose the scale, I cheated by looking at graph of the likelihood)

lower,upper = 36.06,36.095
t = linspace(lower,upper,1000)
ticks = lower:0.005:upper

# Plot histogram
figure(1,figsize=(10,4)); clf(); hold(true)
subplots_adjust(bottom = 0.2)
plt.hist(x,linspace(lower,upper,100))
xlim(lower,upper)
xticks(ticks,ticks)
yticks(0:4)
xlabel("Latitude (degrees)",fontsize=14)
ylim(0,4)
draw_now()
savefig("gps-histogram.png",dpi=120)

# Plot prior, posterior, and proposal densities
figure(2,figsize=(10,4)); clf(); hold(true)
subplots_adjust(bottom = 0.2)
plot(t,pdf(P,t)./maximum(pdf(P,t)),"g",label="prior",linewidth=2)
posterior = [likelihood(x,th)*pdf(P,th) for th in t]
plot(t,posterior./maximum(posterior),"r",label="posterior",linewidth=2)
plot(t,pdf(Q,t)./maximum(pdf(Q,t)),"b",label="proposal",linewidth=2)
xlim(lower,upper)
ylim(0,1.1)
yticks([])
xticks(ticks,ticks)
xlabel("\$\\theta\$  (degrees, latitude)",fontsize=16)
legend(loc="upper right",numpoints=1,labelspacing=0.1,fontsize=15)
draw_now()
savefig("gps-curves.png",dpi=120)

# Approximating the marginal likelihood with simple Monte Carlo versus Importance sampling
N = 10^6

theta = rand(P,N)
MC = cumsum([likelihood(x,th) for th in theta])./[1:N]

theta = rand(Q,N)
IS = cumsum([likelihood(x,th)*pdf(P,th)/pdf(Q,th) for th in theta])./[1:N]

@printf("MC = %.8e\n",MC[end])
@printf("IS = %.8e\n",IS[end])

# Plot approximations over time
figure(3,figsize=(10,4)); clf(); hold(true)
subplots_adjust(bottom = 0.2)
semilogx(1:N,MC,"g",label="Monte Carlo",linewidth=2)
semilogx(1:N,IS,"b",label="Importance sampling",linewidth=2)
xlabel("N  (# of samples used in the approximation)",fontsize=16)
ylabel("approx of \$p(x_{1:n})\$",fontsize=16)
legend(loc="lower right",numpoints=1,labelspacing=0.1,fontsize=15)
draw_now()
savefig("MC-vs-IS.png",dpi=120)

end

