import {isDevMode, NgModule} from '@angular/core';
import {BrowserModule} from '@angular/platform-browser';

import {AppRoutingModule} from './app-routing.module';
import {AppComponent} from './app.component';
import {FontAwesomeModule} from '@fortawesome/angular-fontawesome';
import {HomepageComponent} from './homepage/homepage.component';
import {TermsAndConditionsComponent} from './terms-and-conditions/terms-and-conditions.component';
import {DaylightComponent} from './daylight/daylight.component';
import {LaundrySymbolsComponent} from './laundry-symbols/laundry-symbols.component';
import {WheelOfDrinkingComponent} from './wheel-of-drinking/wheel-of-drinking.component';
import {ServiceWorkerModule} from '@angular/service-worker';
import {CaveMapComponent} from "./cave-map/cave-map.component";

@NgModule({
  declarations: [AppComponent],
  imports: [
    BrowserModule,
    AppRoutingModule,
    FontAwesomeModule,
    HomepageComponent,
    TermsAndConditionsComponent,
    DaylightComponent,
    LaundrySymbolsComponent,
    WheelOfDrinkingComponent,
    CaveMapComponent,
    ServiceWorkerModule.register('ngsw-worker.js', {
      enabled: !isDevMode(),
      // Register the ServiceWorker as soon as the application is stable
      // or after 30 seconds (whichever comes first).
      registrationStrategy: 'registerWhenStable:30000'
    })
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule {
}
