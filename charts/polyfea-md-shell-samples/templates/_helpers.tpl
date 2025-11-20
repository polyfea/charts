{{/*
Expand the name of the chart.
*/}}
{{- define "polyfea-md-shell-samples.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "polyfea-md-shell-samples.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "polyfea-md-shell-samples.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "polyfea-md-shell-samples.labels" -}}
helm.sh/chart: {{ include "polyfea-md-shell-samples.chart" . }}
{{ include "polyfea-md-shell-samples.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
polyfea.github.io/feature-set: polyfea-md-shell
{{- end }}

{{/*
Selector labels
*/}}
{{- define "polyfea-md-shell-samples.selectorLabels" -}}
app.kubernetes.io/name: {{ include "polyfea-md-shell-samples.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
