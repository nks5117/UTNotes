# Fundamental theorem of calculus

The fundamental theorem of calculus is a theorem that links the concept of differentiating a function with the concept of integrating a function.

## Formal statements

There are two parts to the theorem. The first part deals with the derivative of an antiderivative, while the second part deals with the relationship between antiderivatives and definite integrals.

### First part

This part is sometimes referred to as the *first fundamental theorem of calculus*

Let $f$ be a continuous real-valued function defined on a closed interval $[a, b]$. Let $F$ be the function defined, for all $x$ in $[a, b]$, by
$$
F(x) = \int_a^x\!f(t)\,\mathrm{d}t.
$$
Then $F$ is uniformly continuous on $[a, b]$ and differentiable on the open interval $(a, b)$, and
$$
F'(x) = f(x).
$$
for all $x$ in $(a, b)$.

### Second part

This part is sometimes referred to as the *second fundamental theorem of calculus* or the **Newton-Leibniz axiom**.

Let $f$ be a real-valued function on a closed interval $[a, b]$ and $F$ an antiderivative of $f$ in $[a, b]$:
$$
F'(x) = f(x).
$$
If $f$ is Riemann intearable on $[a, b]$, then
$$
\int_a^b\!f(x)\,\mathrm{d}x = F(b) - F(a).
$$