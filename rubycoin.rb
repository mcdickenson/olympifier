require 'distribution'
require 'rinruby'

# the beta distribution
rcode1 = "plot ( density( rbeta(100000, 0.5, 0.5) ), xlim=c(0,1), ylim=c(0, 3), lwd=3, main='betadist')"
rcode2 = "lines( density( rbeta(100000,   1,   1) ), col='blue', lwd=3 )"
rcode3 = "lines( density( rbeta(100000,   5,   5) ), col='red' , lwd=3  )"

R.eval "#{rcode1}"
R.eval "#{rcode2}"
R.eval "#{rcode3}"

# coin flip example
def beta_mode(a,b)
  (a-1).to_f / (a+b-2)
end

def max_like(heads, tails)
  heads.to_f / (heads + tails)
end

x = 25
n = 100
p = 1.quo(4)
like = Distribution::Binomial.pdf(x, n, p)
like = Distribution::Binomial.pdf(x-1, n, p)
like = Distribution::Binomial.pdf(x+1, n, p)

Distribution::Beta.pdf(0.50, 5, 5) # maxima
Distribution::Beta.pdf(0.49, 5, 5)
Distribution::Beta.pdf(0.51, 5, 5)

# set prior
a = b = 5
# a = b = 100
heads = tails = 0
nflips = 3
# nflips = 1000

# pi = 0.5
pi = rand; nil

for flip in 1..nflips
  x = rand
  if x <= pi
    heads += 1 
    print "H"
  else
    tails += 1
    print "T"
  end
end
puts "\n#{heads} heads in #{nflips} flips"


# maximum likelihood
like = Distribution::Binomial.pdf(heads, nflips, 0.5)
like = Distribution::Binomial.pdf(heads, nflips, max_like(heads, tails))
like = Distribution::Binomial.pdf(heads, nflips, max_like(heads, tails)+0.01)
like = Distribution::Binomial.pdf(heads, nflips, max_like(heads, tails)-0.01)
max_like(heads, tails)

# bayes
Distribution::Beta.pdf(beta_mode(a+heads, b+tails), a+heads, b+tails)
beta_mode(a+heads, b+tails)

pi_hat = beta_mode(a+heads, b+tails)

rcode = "plot(  density( rbeta(100000, #{a+heads}, #{b+tails})), xlim=c(0,1) )"
R.eval rcode
