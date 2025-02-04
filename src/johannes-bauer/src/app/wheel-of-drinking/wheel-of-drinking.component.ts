import {Component} from '@angular/core';
import {faAppStoreIos} from '@fortawesome/free-brands-svg-icons';
import {FontAwesomeModule} from '@fortawesome/angular-fontawesome';

@Component({
  selector: 'app-wheel-of-drinking',
  templateUrl: './wheel-of-drinking.component.html',
  styleUrls: ['./wheel-of-drinking.component.css'],
  imports: [FontAwesomeModule]
})
export class WheelOfDrinkingComponent {
  protected readonly faAppStore = faAppStoreIos;
}
