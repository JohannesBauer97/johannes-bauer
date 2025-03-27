import {NgModule} from '@angular/core';
import {RouterModule, Routes} from '@angular/router';
import {HomepageComponent} from './homepage/homepage.component';
import {TermsAndConditionsComponent} from './terms-and-conditions/terms-and-conditions.component';
import {DaylightComponent} from './daylight/daylight.component';
import {LaundrySymbolsComponent} from './laundry-symbols/laundry-symbols.component';
import {WheelOfDrinkingComponent} from "./wheel-of-drinking/wheel-of-drinking.component";
import {ImprintComponent} from "./imprint/imprint.component";
import {PrivacyComponent} from "./privacy/privacy.component";
import {CaveMapComponent} from "./cave-map/cave-map.component";

const routes: Routes = [
  {path: '', component: HomepageComponent},
  {path: 'imprint', component: ImprintComponent},
  {path: 'terms-and-conditions', component: TermsAndConditionsComponent},
  {path: 'privacy-policy', component: PrivacyComponent},
  {path: 'daylight', component: DaylightComponent},
  {path: 'laundry', component: LaundrySymbolsComponent},
  {path: 'partywheel', component: WheelOfDrinkingComponent},
  {path: 'cavemap', component: CaveMapComponent},
  {path: 'daylight-app', redirectTo: 'daylight'},
  {path: 'impress', redirectTo: 'imprint'},
  {path: '**', redirectTo: ''}
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule {
}
