# trace_parser
An utility to calculate utilization using a result of utilization_mon

## An example for mobilenetv1
```
$> python trace_parser.py -i profile.json -u util.json
Maximum GOPS for  32 x 32  MACs @ 0.2 GHz =  409.6
Layer      Target Opts     Runtime(ns)     Utilization(%)
layer0     20471808        766650          19.56
layer1     6823936         323220          15.46
layer2     50577408        640060          57.88
layer3     3411968         421340          5.93
layer4     50978816        515040          72.50
layer5     6823936         356400          14.02
layer6     102359040       836600          89.61
layer7     1705984         238560          5.24
layer8     51179520        526360          71.22
layer9     3411968         233740          10.69
layer10    51279872        467240          80.38
layer11    426496          80920           3.86
layer12    12819968        214960          43.68
layer13    852992          69620           8.97
layer14    25665024        214790          87.52
layer15    852992          29200           21.40
layer16    25665024        214790          87.52
layer17    852992          29200           21.40
layer18    25665024        214790          87.52
layer19    852992          29200           21.40
layer20    25665024        214790          87.52
layer21    852992          29200           21.40
layer22    25665024        214790          87.52
Overall utilization:  52.67 %
```

## Usage
```
$> python trace_parser.py --help
usage: trace_parser.py [-h] [--input INPUT] [--util UTIL] [--debug]

help

optional arguments:
  -h, --help            show this help message and exit
  --input INPUT, -i INPUT
                        simulation profile result(json file)
  --util UTIL, -u UTIL  data to calculate utilization for each layer(json file)
  --debug, -d           manual debug mode

```
