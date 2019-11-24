<template>
  <q-page class="flex flex-center">
    <div class="row">
      <q-card flat bordered class="my-card bg-primary">
        <q-card-section>
          <div class="row items-center no-wrap">
            <div class="col">
              <div class="text-h6">Quickplay</div>
            </div>
          </div>
        </q-card-section>

        <q-card-section>
          <div class="row">
            <q-card flat bordered class="my-card bg-secondary">
              <q-card-section>
                <div class="row items-center no-wrap">
                  <div class="col">
                    <div class="text-h6">Woodswalker Khandrish</div>
                    <div class="text-subtitle2">Tales of Arcadia</div>
                  </div>
                </div>
              </q-card-section>

              <q-separator />

              <q-card-actions align="around">
                <q-btn flat>Play</q-btn>
                <q-btn flat>View</q-btn>
                <q-btn flat>Dismiss</q-btn>
              </q-card-actions>
            </q-card>
            <q-card flat bordered class="my-card bg-secondary">
              <q-card-section>
                <div class="row items-center no-wrap">
                  <div class="col">
                    <div class="text-h6">Hunter Silvanne</div>
                    <div class="text-subtitle2">Tales of Arcadia</div>
                  </div>
                </div>
              </q-card-section>

              <q-separator />

              <q-card-actions align="around">
                <q-btn flat>Play</q-btn>
                <q-btn flat>View</q-btn>
                <q-btn flat>Dismiss</q-btn>
              </q-card-actions>
            </q-card>
          </div>
        </q-card-section>

        <q-separator />

        <q-card-actions>
          <q-btn flat>Dismiss</q-btn>
        </q-card-actions>
      </q-card>
    </div>
  </q-page>
</template>

<style>
</style>

<script>

export default {
  name: 'LandingPage',
  components: { }
}
</script>
