Figure 1 Long Description

Overall Layout and Visual Metaphor
The figure consists of six scatter plots labeled A through F, arranged in two rows of three. Each plot illustrates the distribution of a network's eigenvalues on a complex plane to show conditions for stability. The horizontal axis represents the Real part and the vertical axis represents the Imaginary part. The vertical Imaginary axis serves as the critical boundary for network stability. Eigenvalues to its left are stable, while any crossing to its right destabilize the system. In all panels, the vast majority of eigenvalues, referred to as the bulk, are represented by hundreds of hollow black circles bound within a solid black circular outline. Outlier eigenvalues that escape this main boundary are highlighted as solid green dots.

Subpanel Details

Subpanel A shows the Real and Imaginary axes crossing in the exact center of the circular black bulk, meaning the eigenvalues are centered around zero. However, a single green outlier dot sits far to the right of the bulk on the horizontal Real axis, pushed into the unstable region due to a slightly positive mean synaptic weight.

Subpanel B demonstrates stabilization via negative feedback. The entire circular bulk of eigenvalues is shifted leftward so that the vertical Imaginary axis tangentially touches the rightmost edge of the circle. All eigenvalues are resting exactly on the edge of stability within the left half-plane, and there are no green outliers.

Subpanel C illustrates the destabilizing effect of Dale's law. The main circular bulk is positioned against the Imaginary axis exactly as in Panel B. However, several green outlier dots have emerged, scattered outside the circular boundary. Crucially, a few of these green outliers cross the vertical Imaginary axis to the right into the unstable region.

Subpanel D shows the effect of perfectly balancing excitatory and inhibitory input weights. The layout is visually identical to Panel B. The main circle rests against the vertical Imaginary axis, and all green outliers have been successfully pulled back into the bulk. The system is stable.

Subpanel E shows the effect of unequal weight standard deviations. The main bulk is again bounded by the vertical Imaginary axis with no green outliers present. However, unlike the evenly distributed dots in the other panels, the hollow black circles here are intensely clustered in the very center of the circular region, becoming sparse toward the outer boundary.

Subpanel F illustrates the failure of input balancing in sparse networks with fifty percent density. The main circular bulk remains against the vertical Imaginary axis, but several green outlier dots have reappeared around the top, bottom, and right edges of the boundary. A few of these outliers cross the Imaginary axis into the unstable right half-plane. This demonstrates that structural balancing cannot constrain outliers in sparse networks, visually setting up the need for dynamic adaptation.
