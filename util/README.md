# trace_parser
An utility to calculate utilization using a result of utilization_mon

## An example for mobilenetv1
```
$> python trace_parser.py -i profile.json -u util.json
Maximum GOPS for  32 x 32  MACs @ 0.1 GHz =  204.8
Layer      Target Opts     Runtime(ns)     Utilization(%)
layer0     20471808        766650          13.04
layer1     6823936         323220          10.31
layer2     50577408        640060          38.58
layer3     3411968         421340          3.95
layer4     50978816        515040          48.33
layer5     6823936         356400          9.35
layer6     102359040       836600          59.74
layer7     1705984         238560          3.49
layer8     51179520        526360          47.48
layer9     3411968         233740          7.13
layer10    51279872        467240          53.59
layer11    426496          80920           2.57
layer12    12819968        214960          29.12
layer13    852992          69620           5.98
layer14    25665024        214790          58.34
layer15    852992          29200           14.26
layer16    25665024        214790          58.34
layer17    852992          29200           14.26
layer18    25665024        214790          58.34
layer19    852992          29200           14.26
layer20    25665024        214790          58.34
layer21    852992          29200           14.26
layer22    25665024        214790          58.34
Overall utilization:  35.11 %
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
  --debugutil, -du      debug mode to calculate runtime ratio, average utilization for target layers
```
