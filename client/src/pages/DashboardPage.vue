<template>
  <q-page class="dashboardPage">
    <div class="dashboardContainer row full-width">

      <q-splitter
        class="dashboardSplitter"
        v-model="splitterModel"
      >

        <template v-slot:before>
          <q-tabs
            v-model="tab"
            vertical
            class="dashboardTabs text-teal"
          >
            <q-tab
              name="quickActions"
              icon="fas fa-stopwatch"
              label="Quick Actions"
              class="dashboardTab"
            />
            <q-tab
              name="alarms"
              icon="alarm"
              label="Alarms"
              class="dashboardTab"
            />
            <q-tab
              name="movies"
              icon="movie"
              label="Movies"
              class="dashboardTab"
            />
          </q-tabs>
        </template>

        <template v-slot:after>
          <q-tab-panels
            v-model="tab"
            animated
            transition-prev="jump-up"
            transition-next="jump-up"
          >
            <q-tab-panel name="quickActions">
              <q-card
                flat
                bordered
                class="my-card bg-primary"
              >
                <q-card-section>
                  <div class="q-pa-md">
                    <q-table
                      title="Quickplay"
                      :data="data"
                      :columns="columns"
                      table-style="max-height: 400px"
                      row-key="index"
                      virtual-scroll
                      :pagination.sync="pagination"
                      :rows-per-page-options="[0]"
                    />
                  </div>
                </q-card-section>

                <q-separator />

                <q-card-actions>
                  <q-btn flat>Dismiss</q-btn>
                </q-card-actions>
              </q-card>
            </q-tab-panel>

            <q-tab-panel name="alarms">
              <div class="text-h4 q-mb-md">Alarms</div>
              <p>Lorem ipsum dolor sit, amet consectetur adipisicing elit. Quis praesentium cumque magnam odio iure quidem, quod illum numquam possimus obcaecati commodi minima assumenda consectetur culpa fuga nulla ullam. In, libero.</p>
              <p>Lorem ipsum dolor sit, amet consectetur adipisicing elit. Quis praesentium cumque magnam odio iure quidem, quod illum numquam possimus obcaecati commodi minima assumenda consectetur culpa fuga nulla ullam. In, libero.</p>
            </q-tab-panel>

            <q-tab-panel name="movies">
              <div class="text-h4 q-mb-md">Movies</div>
              <p>Lorem ipsum dolor sit, amet consectetur adipisicing elit. Quis praesentium cumque magnam odio iure quidem, quod illum numquam possimus obcaecati commodi minima assumenda consectetur culpa fuga nulla ullam. In, libero.</p>
              <p>Lorem ipsum dolor sit, amet consectetur adipisicing elit. Quis praesentium cumque magnam odio iure quidem, quod illum numquam possimus obcaecati commodi minima assumenda consectetur culpa fuga nulla ullam. In, libero.</p>
              <p>Lorem ipsum dolor sit, amet consectetur adipisicing elit. Quis praesentium cumque magnam odio iure quidem, quod illum numquam possimus obcaecati commodi minima assumenda consectetur culpa fuga nulla ullam. In, libero.</p>
            </q-tab-panel>
          </q-tab-panels>
        </template>

      </q-splitter>

    </div>
  </q-page>
</template>

<style>
</style>

<script>
const seed = [
  {
    name: 'Frozen Yogurt',
    calories: 159,
    fat: 6.0,
    carbs: 24,
    protein: 4.0,
    sodium: 87,
    calcium: '14%',
    iron: '1%'
  },
  {
    name: 'Ice cream sandwich',
    calories: 237,
    fat: 9.0,
    carbs: 37,
    protein: 4.3,
    sodium: 129,
    calcium: '8%',
    iron: '1%'
  },
  {
    name: 'Eclair',
    calories: 262,
    fat: 16.0,
    carbs: 23,
    protein: 6.0,
    sodium: 337,
    calcium: '6%',
    iron: '7%'
  },
  {
    name: 'Cupcake',
    calories: 305,
    fat: 3.7,
    carbs: 67,
    protein: 4.3,
    sodium: 413,
    calcium: '3%',
    iron: '8%'
  },
  {
    name: 'Gingerbread',
    calories: 356,
    fat: 16.0,
    carbs: 49,
    protein: 3.9,
    sodium: 327,
    calcium: '7%',
    iron: '16%'
  },
  {
    name: 'Jelly bean',
    calories: 375,
    fat: 0.0,
    carbs: 94,
    protein: 0.0,
    sodium: 50,
    calcium: '0%',
    iron: '0%'
  },
  {
    name: 'Lollipop',
    calories: 392,
    fat: 0.2,
    carbs: 98,
    protein: 0,
    sodium: 38,
    calcium: '0%',
    iron: '2%'
  },
  {
    name: 'Honeycomb',
    calories: 408,
    fat: 3.2,
    carbs: 87,
    protein: 6.5,
    sodium: 562,
    calcium: '0%',
    iron: '45%'
  },
  {
    name: 'Donut',
    calories: 452,
    fat: 25.0,
    carbs: 51,
    protein: 4.9,
    sodium: 326,
    calcium: '2%',
    iron: '22%'
  },
  {
    name: 'KitKat',
    calories: 518,
    fat: 26.0,
    carbs: 65,
    protein: 7,
    sodium: 54,
    calcium: '12%',
    iron: '6%'
  }
]

// we generate lots of rows here
let data = []
for (let i = 0; i < 1000; i++) {
  data = data.concat(seed.slice(0).map(r => ({ ...r })))
}
data.forEach((row, index) => {
  row.index = index
})

// we are not going to change this array,
// so why not freeze it to avoid Vue adding overhead
// with state change detection
Object.freeze(data)

export default {
  name: 'LandingPage',
  data() {
    return {
      data,

      pagination: {
        rowsPerPage: 0
      },
      columns: [
        {
          name: 'index',
          label: 'Character',
          field: 'index'
        },
        {
          name: 'mud',
          required: true,
          label: 'MUD',
          align: 'left',
          field: row => row.name,
          format: val => `${val}`,
          sortable: true
        },
        { name: 'calories', align: 'center', label: 'Hours Played', field: 'calories', sortable: true },
        { name: 'fat', label: 'Last Played', field: 'fat', sortable: true },
        { name: 'carbs', label: 'Created', field: 'carbs' },
        { name: 'protein', label: 'Gender/Sex', field: 'protein' },
        { name: 'sodium', label: 'Race', field: 'sodium' },
        { name: 'calcium', label: 'Age', field: 'calcium', sortable: true, sort: (a, b) => parseInt(a, 10) - parseInt(b, 10) },
        { name: 'iron', label: 'Iron (%)', field: 'iron', sortable: true, sort: (a, b) => parseInt(a, 10) - parseInt(b, 10) }
      ],
      tab: 'quickActions'
    }
  }
}
</script>
