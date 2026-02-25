Figure 2 Long Description

Overall Layout and Visual Metaphor
The figure consists of seven panels labeled A through G that demonstrate how physiological adaptation mechanisms affect the dynamical stability of a recurrent neural network. The figure uses color coding throughout where red indicates excitatory elements and blue indicates inhibitory elements.

Subpanel Details

Subpanel A is a heatmap of a synaptic connection matrix for a network of three hundred neurons. The left half is composed of red speckles representing excitatory weights, and the right half has blue speckles for inhibitory weights. It is sparse, with mostly white space representing zero values.

Subpanel B is a histogram of these synaptic weights. It shows two overlapping bell curves. The red curve for excitatory connections is centered at a positive value, while the blue curve for inhibitory connections is centered at a slightly larger magnitude negative value, illustrating inhibitory dominance.

Subpanel C is a scatter plot on the complex plane showing the eigenvalues of this basic network without adaptation. While most eigenvalues sit inside a circular bulk, several outlier eigenvalues marked as green dots fall to the right of the vertical imaginary axis, placing them in the unstable region.

Subpanel D contains two side-by-side columns of time series graphs. The left column shows a network with only spike frequency adaptation, or SFA. The right column shows a network with both SFA and short-term synaptic depression, or STD. Each column stacks six traces from top to bottom. First is the stimulus pulse over a period of ten seconds. Below this are the voltage traces of the dendrites, followed by synaptic output, adaptation state, synaptic depression state, and finally the local largest Lyapunov exponent. In the SFA only network, during the stimulus, the neuronal signals become highly erratic and the Lyapunov exponent fluctuates above zero, indicating chaos. In contrast, the network with both SFA and STD shows the depression state dropping closer to zero during the stimulus. This limits the chaotic fluctuations, maintaining the neuronal signals and Lyapunov exponent in a consistent state near zero.

Subpanel E displays heatmaps of the effective connectivity matrices for both network types halfway through the stimulation and no stimulation periods. Both the SFA only network and the network with both SFA and STD display prominent vertical white bands during both the stimulation and no-stimulation periods, which become especially pronounced during the stimulation. This visually demonstrates that nonlinearity and adaptation dynamically modulate the network by temporarily silencing certain neuronal columns.

Subpanel F shows scatter plots of the eigenvalues of the full Jacobian corresponding to the effective connectivity matrices in panel E. For the SFA only network, the eigenvalues spread out widely. For the network with both SFA and STD, the eigenvalues become slightly more tightly clustered and are pulled slightly leftward, closer to stability.

Subpanel G consists of four dot and line plots summarizing the change in the local Lyapunov exponent between the stimulated and the not-stimulated state across twenty five random network initializations. Each plot represents a different adaptation condition. The networks with no adaptation or SFA only show a significant downward shift during the no stimulation period, indicating receding chaos. However, networks with STD only or both SFA and STD show mostly flat, horizontal lines indicating no significant change in stability. The data points are colored by the ratio of excitatory to inhibitory neurons, showing that the combination of SFA and STD robustly maintains the system near the edge of chaos regardless of underlying structural imbalance.
