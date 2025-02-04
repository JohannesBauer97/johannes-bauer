import {Component} from '@angular/core';
import {faAppStoreIos} from '@fortawesome/free-brands-svg-icons';
import {FontAwesomeModule} from '@fortawesome/angular-fontawesome';

@Component({
  selector: 'app-daylight',
  templateUrl: './daylight.component.html',
  styleUrls: ['./daylight.component.css'],
  imports: [FontAwesomeModule]
})
export class DaylightComponent {
  protected readonly faAppStore = faAppStoreIos;
}
