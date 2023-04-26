import dataclasses

import numpy as np
import pytest
import nest
import testutil, testsimulation


@dataclasses.dataclass
class IAFPSCAlphaDCSimulation(testsimulation.Simulation):
    amplitude: float = 1000.0
    origin: float = 0.0
    arrival: float = 3.0
    dc_delay: float = 1.0
    dc_visible: float = 3.0
    dc_duration: float = 2.0

    def __post_init__(self):
        self.dc_on = self.dc_visible - self.dc_delay
        self.dc_off = self.dc_on + self.dc_duration

    def setup(self):
        super().setup()
        n1 = self.neuron = nest.Create("iaf_psc_alpha")
        dc = self.dc_generator = nest.Create("dc_generator")
        dc.amplitude = self.amplitude
        vm = self.voltmeter = nest.Create("voltmeter")
        vm.interval = self.resolution
        nest.Connect(vm, n1)


@pytest.mark.parametrize("weight", [1.0])
@testutil.use_simulation(IAFPSCAlphaDCSimulation)
class TestIAFPSCAlphaDC:
    @pytest.mark.parametrize("delay", [0.1])
    def test_dc(self, simulation):
        simulation.setup()

        dc_gen_spec = {"delay": simulation.delay, "weight": simulation.weight}
        nest.Connect(simulation.dc_generator, simulation.neuron, syn_spec=dc_gen_spec)

        results = simulation.simulate()

        actual, expected = testutil.get_comparable_timesamples(results, expect_default)
        assert actual == expected

    @pytest.mark.parametrize(
        "resolution,delay", [(0.1, 0.1), (0.2, 0.2), (0.5, 0.5), (1.0, 1.0)]
    )
    def test_dc_aligned(self, simulation):
        simulation.setup()

        simulation.dc_generator.set(
            amplitude=simulation.amplitude,
            origin=simulation.origin,
            start=simulation.arrival - simulation.resolution,
        )
        nest.Connect(
            simulation.dc_generator,
            simulation.neuron,
            syn_spec={"delay": simulation.delay},
        )

        results = simulation.simulate()

        actual, expected = testutil.get_comparable_timesamples(results, expect_aligned)
        assert actual == expected

    @pytest.mark.parametrize(
        "resolution,delay", [(0.1, 0.1), (0.2, 0.2), (0.5, 0.5), (1.0, 1.0)]
    )
    def test_dc_aligned_auto(self, simulation):
        simulation.setup()

        simulation.dc_generator.set(
            amplitude=simulation.amplitude,
            origin=simulation.origin,
            start=simulation.dc_on,
        )
        dc_gen_spec = {"delay": simulation.dc_delay, "weight": simulation.weight}
        nest.Connect(simulation.dc_generator, simulation.neuron, syn_spec=dc_gen_spec)

        results = simulation.simulate()
        actual, expected = testutil.get_comparable_timesamples(results, expect_auto)
        assert actual == expected

    @pytest.mark.parametrize(
        "resolution,delay", [(0.1, 0.1), (0.2, 0.2), (0.5, 0.5), (1.0, 1.0)]
    )
    @pytest.mark.parametrize("duration", [10.0])
    def test_dc_aligned_stop(self, simulation):
        simulation.setup()

        simulation.dc_generator.set(
            amplitude=simulation.amplitude,
            origin=simulation.origin,
            start=simulation.dc_on,
            stop=simulation.dc_off,
        )
        dc_gen_spec = {"delay": simulation.dc_delay, "weight": simulation.weight}
        nest.Connect(simulation.dc_generator, simulation.neuron, syn_spec=dc_gen_spec)

        results = simulation.simulate()
        actual, expected = testutil.get_comparable_timesamples(results, expect_stop)
        assert actual == expected


expect_default = np.array(
    [
        [0.1, -70],  #   <--------   is at rest (initial condition).
        [0.2, -70],  # <-------   |
        [
            0.3,
            -69.602,
        ],  # <-  |   - In the first update step 0ms  -> 0.1 ms, i.e. at
        [
            0.4,
            -69.2079,
        ],  #  | |     the earliest possible time, the current generator
        [
            0.5,
            -68.8178,
        ],  #  | |     is switched on and emits a current event with time
        [0.6, -68.4316],  #  | |     stamp 0.1 ms.
        [0.7, -68.0492],  #  | |
        [
            0.8,
            -67.6706,
        ],  #  |  ---- After the minimal delay of 1 computation time step,
        [
            0.9,
            -67.2958,
        ],  #  |       the current affects the state of the neuron. This is
        [
            1.0,
            -66.9247,
        ],  #  |       reflected in the neuron's state variable y0 (initial
        [
            1.1,
            -66.5572,
        ],  #  |       condition) but has not yet affected the membrane
        [1.2, -66.1935],  #  |       potential.
        [1.3, -65.8334],  #  |
        [
            1.4,
            -65.4768,
        ],  #   ------ The effect of the DC current, influencing the neuron
        [
            1.5,
            -65.1238,
        ],  #          for 0.1 ms now, becomes visible in the membrane potential.
        [1.6, -64.7743],  #
    ]
)


expect_aligned = np.array(
    [
        [2.5, -70],  #
        [2.6, -70],  #
        [2.7, -70],  #
        [2.8, -70],  #
        [2.9, -70],  #
        [3.0, -70],  #  %  <---- Current starts to affect
        [3.1, -69.602],  #   %   neuron (visible in state variable
        [3.2, -69.2079],  #  %   y0). This is the desired onset of
        [3.3, -68.8178],  #  %    t= 3.0 ms.
        [3.4, -68.4316],  #
        [3.5, -68.0492],  #
        [3.6, -67.6706],  #
        [3.7, -67.2958],  #
        [3.8, -66.9247],  #
        [3.9, -66.5572],  #
        [4.0, -66.1935],  #
        [4.1, -65.8334],  #
        [4.2, -65.4768],  #
    ]
)


expect_auto = np.array(
    [
        [2.5, -70],  #
        [2.6, -70],  #
        [2.7, -70],  #
        [2.8, -70],  #
        [2.9, -70],  #
        [3.0, -70],  #  %  <---- Current starts to affect
        [3.1, -69.602],  #   %   neuron (visible in state variable
        [3.2, -69.2079],  #  %   y0). This is the desired onset of
        [3.3, -68.8178],  #  %    t= 3.0 ms.
        [3.4, -68.4316],  #
        [3.5, -68.0492],  #
        [3.6, -67.6706],  #
        [3.7, -67.2958],  #
        [3.8, -66.9247],  #
        [3.9, -66.5572],  #
        [4.0, -66.1935],  #
        [4.1, -65.8334],  #
        [4.2, -65.4768],  #
    ]
)


expect_stop = np.array(
    [
        [2.5, -70],  #
        [2.6, -70],  #
        [2.7, -70],  #
        [2.8, -70],  #
        [2.9, -70],  #
        [3.0, -70],  #          <-- current starts to affect
        [3.1, -69.602],  #  %         neuron (visible in state variable
        [3.2, -69.2079],  #  %       y0). This is the desired onset of
        [3.3, -68.8178],  #  %       t= 3.0 ms.
        [3.4, -68.4316],  #
        [3.5, -68.0492],  #
        [3.6, -67.6706],  #
        [3.7, -67.2958],  #
        [3.8, -66.9247],  #
        [3.9, -66.5572],  #
        [4.0, -66.1935],  #
        [4.1, -65.8334],  #
        [4.2, -65.4768],  #
        [4.3, -65.1238],  #
        [4.4, -64.7743],  #
        [4.5, -64.4283],  #
        [4.6, -64.0858],  #
        [4.7, -63.7466],  #
        [4.8, -63.4108],  #
        [4.9, -63.0784],  #
        [5.0, -62.7492],  #    <-- current ends to affect neuron
        [5.1, -62.8214],  #        (visible in state variable y0),
        [5.2, -62.8928],  #        the highest voltage is observed.
        [5.3, -62.9635],  #        The current was applied for the desired
        [5.4, -63.0335],  #        duration (2ms).
        [5.5, -63.1029],  #
        [5.6, -63.1715],  #
        [5.7, -63.2394],  #
        [5.8, -63.3067],  #
        [5.9, -63.3733],  #
        [6.0, -63.4392],  #
    ]
)
