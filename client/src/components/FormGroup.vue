<template>
  <q-field
    v-bind="$attrs"
    :label="label"
    :error="hasErrors"
    :error-label="firstErrorMessage"
  >
    <slot />
  </q-field>
</template>
<script>
import { singleErrorExtractorMixin } from 'vuelidate-error-extractor'

export default {
  name: 'FormGroup',
  extends: singleErrorExtractorMixin,
  inheritAttrs: false
}
</script>
