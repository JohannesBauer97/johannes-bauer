import {Component} from '@angular/core';
import {faAppStoreIos} from '@fortawesome/free-brands-svg-icons';
import {FontAwesomeModule} from '@fortawesome/angular-fontawesome';

@Component({
  selector: 'app-laundry-symbols',
  templateUrl: './laundry-symbols.component.html',
  styleUrls: ['./laundry-symbols.component.scss'],
  imports: [FontAwesomeModule]
})
export class LaundrySymbolsComponent {
  protected readonly faAppStore = faAppStoreIos;
}
