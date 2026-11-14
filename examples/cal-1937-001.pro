::meta
title: CAL-1937-001
version: 1.0.0
fixture: CAL-1937-001
domain: bio/med
fields: robotic|synthetic
scope: all
::end

::schema
node-types: [procedure, step, gate, transform, environment, version, meta]
edge-types: [contains, precedes, couples, restricts, inverts, writes, senses, refuses]
fields: [robotic, synthetic]
opens: [none, a, b, ab]
payload-classes: [empty, water]
scopes: [all, agent, orchestrator]
::end

::index
# id | type | scope | keywords
proc | procedure | all | calibration, water, two-channel
gamma | transform | all | V4, toggle-a, toggle-b
adapt | transform | all | restrict, sheaf
env-0 | environment | all | hardware A B, open ab
env-1 | environment | all | hardware A, fault, open a
step-home | step | all | home, robotic
step-asp-a | step | all | aspirate, A
step-disp-a | step | all | dispense, A
step-asp-b | step | all | aspirate, B
step-disp-b | step | all | dispense, B
slot-a | step | all | water, synthetic
slot-b | step | all | water, synthetic
gate-section | gate | all | support, pairing
gate-payload | gate | all | empty, water
ver-0 | version | all | anchor, open ab
ver-1 | version | all | restrict, open a
ver-2 | version | all | toggle-a, current
trace | meta | all | cycles, refusal
__view | meta | all | mermaid
::end

::node [id=proc type=procedure scope=all entry=true current=ver-2]
::dense CAL-1937-001 | water calibration | group V4 | sheaf on hardware
::warning
Read DISCLAIMER before any node. Act returns a specification. It does not command hardware.
::end
->[:contains] gamma, adapt, env-0, env-1, step-home, step-asp-a, step-disp-a, step-asp-b, step-disp-b, slot-a, slot-b, gate-section, gate-payload, ver-0, ver-1, ver-2, trace, __view
::end

::node [id=gamma type=transform scope=all kind=group presentation=V4]
::dense generators toggle-a, toggle-b | a^2=b^2=e | ab=ba | right action | inverse is the generator
->[:inverts] gamma
->[:writes] ver-2
::end

::node [id=adapt type=transform scope=all kind=restrict]
::dense sheaf restriction | not a group element | inverse absent | rollback is the parent version
->[:restricts] env-1
->[:writes] ver-1
::end

::node [id=env-0 type=environment scope=all open=ab]
::dense hardware A,B | operators home, aspirate, dispense | constraints channels-not-isomorphic | updates empty
::end

::node [id=env-1 type=environment scope=all open=a]
::dense hardware A | operators home, aspirate, dispense | constraints channels-not-isomorphic | updates channel-b-fault
::end

::node [id=step-home type=step field=robotic operator=home hardware=none]
::dense home | enabled in every version
->[:precedes] step-asp-a, step-asp-b
::end

::node [id=step-asp-a type=step field=robotic operator=aspirate hardware=A]
::dense aspirate A | paired with dispense A
->[:precedes] step-disp-a
->[:couples] slot-a
::end

::node [id=step-disp-a type=step field=robotic operator=dispense hardware=A]
::dense dispense A | paired with aspirate A
->[:couples] slot-a
::end

::node [id=step-asp-b type=step field=robotic operator=aspirate hardware=B]
::dense aspirate B | paired with dispense B
->[:precedes] step-disp-b
->[:couples] slot-b
::end

::node [id=step-disp-b type=step field=robotic operator=dispense hardware=B]
::dense dispense B | paired with aspirate B
->[:couples] slot-b
::end

::node [id=slot-a type=step field=synthetic payload-class=water volume=10 unit=uL vessel=calibration-plate]
::dense slot A | calibrant water | outside the robotic marking
::end

::node [id=slot-b type=step field=synthetic payload-class=water volume=10 unit=uL vessel=calibration-plate]
::dense slot B | calibrant water | outside the robotic marking
::end

::node [id=gate-section type=gate scope=all]
::dense enabled hardware lies in the open | one channel's aspirate and dispense move together
::warning
A step whose hardware is outside the open is dropped, not retargeted. Channel A and channel B are not interchangeable.
::end
::end

::node [id=gate-payload type=gate scope=all]
::dense payload-class is empty or water | volume, unit, and vessel are fixture attributes
::warning
The grammar has no attribute for a sequence, an organism, a strain, or a toxin. Orchestrator scope does not add one.
::end
::end

::node [id=ver-0 type=version scope=all current=false writer=none parent=none transform=id inverse=none rel=e open=ab enabled=home,asp-a,disp-a,asp-b,disp-b]
::dense anchor | A on | B on
->[:senses] env-0
::end

::node [id=ver-1 type=version scope=all current=false writer=agent parent=ver-0 transform=restrict inverse=none rel=e open=a enabled=home,asp-a,disp-a]
::dense local procedure | B off | rollback is ver-0
::warning
Channel B is outside the open. Do not move asp-b or disp-b onto channel A.
::end
->[:senses] env-1
::end

::node [id=ver-2 type=version scope=all current=true writer=agent parent=ver-1 transform=toggle-a inverse=toggle-a rel=a open=a enabled=home]
::dense current | A off | B off | slots remain | couples to A are inactive
->[:senses] env-1
::end

::node [id=trace type=meta scope=all]
::dense cycle0 read:id | cycle1 write:restrict proposal:toggle-a | cycle2 write:toggle-a | cycle3 refuse:ill-formed proposal:other writer:agent | cycle4 refuse:ill-formed proposal:other writer:orchestrator
::end

::node [id=__view type=meta scope=all]
::dense version chain | type graph is not the ver-2 marking
```mermaid
stateDiagram-v2
  direction LR
  [*] --> v0
  v0 --> v1: restrict to open a
  v1 --> v2: toggle-a
  v2 --> v2: other refused
```
```mermaid
flowchart LR
  home --> aspA[asp-a]
  home --> aspB[asp-b]
  aspA --> dispA[disp-a]
  aspB --> dispB[disp-b]
  aspA --- slotA[slot-a water]
  dispA --- slotA
  aspB --- slotB[slot-b water]
  dispB --- slotB
```
::end
