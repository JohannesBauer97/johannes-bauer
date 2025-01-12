import {Component} from '@angular/core';
import {faGithub, faLinkedin, faXing} from '@fortawesome/free-brands-svg-icons';
import {faEnvelope} from '@fortawesome/free-regular-svg-icons';
import {RouterLink} from '@angular/router';
import {FontAwesomeModule} from '@fortawesome/angular-fontawesome';

@Component({
  selector: 'app-homepage',
  templateUrl: './homepage.component.html',
  styleUrls: ['./homepage.component.scss'],
  imports: [FontAwesomeModule, RouterLink]
})
export class HomepageComponent {
  protected readonly faGithub = faGithub;
  protected readonly faEnvelope = faEnvelope;
  protected readonly faXing = faXing;
  protected readonly faLinkedIn = faLinkedin;
}
